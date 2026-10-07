-- WASEL ride marketplace: real passenger requests, driver offers and passenger acceptance.
-- Run this once in the Supabase SQL Editor.

create table if not exists public.ride_offers (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null references public.rides(id) on delete cascade,
  driver_id uuid not null references public.profiles(id) on delete cascade,
  proposed_fare numeric not null check (proposed_fare > 0),
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (ride_id, driver_id)
);

alter table public.ride_offers enable row level security;

create or replace function public.create_ride_request(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_destination_lat double precision,
  p_destination_lng double precision,
  p_pickup_address text,
  p_destination_address text,
  p_vehicle_type text,
  p_passengers integer,
  p_suggested_fare numeric,
  p_notes text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_ride_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  insert into public.rides (
    passenger_id,
    driver_id,
    pickup_lat,
    pickup_lng,
    destination_lat,
    destination_lng,
    pickup_address,
    destination_address,
    vehicle_type,
    passengers,
    suggested_fare,
    accepted_fare,
    notes,
    status,
    created_at,
    updated_at
  )
  values (
    auth.uid(),
    null,
    p_pickup_lat,
    p_pickup_lng,
    p_destination_lat,
    p_destination_lng,
    coalesce(p_pickup_address, ''),
    coalesce(p_destination_address, ''),
    coalesce(p_vehicle_type, ''),
    greatest(coalesce(p_passengers, 1), 1),
    greatest(coalesce(p_suggested_fare, 0), 0),
    null,
    coalesce(p_notes, ''),
    'pending',
    now(),
    now()
  )
  returning id into new_ride_id;

  return new_ride_id;
end;
$$;

create or replace function public.driver_list_pending_rides()
returns table (
  id uuid,
  passenger_id uuid,
  pickup_lat double precision,
  pickup_lng double precision,
  destination_lat double precision,
  destination_lng double precision,
  pickup_address text,
  destination_address text,
  vehicle_type text,
  passengers integer,
  suggested_fare numeric,
  notes text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    r.id,
    r.passenger_id,
    r.pickup_lat,
    r.pickup_lng,
    r.destination_lat,
    r.destination_lng,
    r.pickup_address,
    r.destination_address,
    r.vehicle_type,
    r.passengers,
    r.suggested_fare,
    r.notes,
    r.created_at
  from public.rides r
  join public.profiles p on p.id = auth.uid()
  where (
      p.role in ('driver', 'admin')
      or p.requested_account_type = 'driver'
    )
    and p.is_active = true
    and r.status = 'pending'
    and r.passenger_id <> auth.uid()
  order by r.created_at desc
  limit 100;
$$;

create or replace function public.submit_ride_offer(
  p_ride_id uuid,
  p_proposed_fare numeric
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_offer_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  if p_proposed_fare is null or p_proposed_fare <= 0 then
    raise exception 'invalid fare';
  end if;

  if not exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.is_active = true
      and (
        p.role in ('driver', 'admin')
        or p.requested_account_type = 'driver'
      )
  ) then
    raise exception 'driver account required';
  end if;

  if not exists (
    select 1
    from public.rides r
    where r.id = p_ride_id
      and r.status = 'pending'
      and r.passenger_id <> auth.uid()
  ) then
    raise exception 'ride is not available';
  end if;

  insert into public.ride_offers (
    ride_id,
    driver_id,
    proposed_fare,
    status,
    created_at,
    updated_at
  )
  values (
    p_ride_id,
    auth.uid(),
    p_proposed_fare,
    'pending',
    now(),
    now()
  )
  on conflict (ride_id, driver_id)
  do update
  set
    proposed_fare = excluded.proposed_fare,
    status = 'pending',
    updated_at = now()
  returning id into new_offer_id;

  return new_offer_id;
end;
$$;

create or replace function public.passenger_list_ride_offers(
  p_ride_id uuid
)
returns table (
  id uuid,
  driver_id uuid,
  driver_name text,
  driver_phone text,
  proposed_fare numeric,
  status text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    o.id,
    o.driver_id,
    coalesce(p.full_name, ''),
    coalesce(p.phone, ''),
    o.proposed_fare,
    o.status,
    o.created_at
  from public.ride_offers o
  join public.rides r on r.id = o.ride_id
  left join public.profiles p on p.id = o.driver_id
  where o.ride_id = p_ride_id
    and r.passenger_id = auth.uid()
  order by o.status = 'accepted' desc, o.proposed_fare asc, o.created_at asc;
$$;

create or replace function public.accept_ride_offer(
  p_offer_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_ride_id uuid;
  selected_driver_id uuid;
  selected_fare numeric;
begin
  select
    o.ride_id,
    o.driver_id,
    o.proposed_fare
  into
    selected_ride_id,
    selected_driver_id,
    selected_fare
  from public.ride_offers o
  join public.rides r on r.id = o.ride_id
  where o.id = p_offer_id
    and r.passenger_id = auth.uid()
    and o.status = 'pending'
    and r.status = 'pending'
  for update of o, r;

  if selected_ride_id is null then
    raise exception 'offer is no longer available';
  end if;

  update public.rides
  set
    driver_id = selected_driver_id,
    accepted_fare = selected_fare,
    status = 'accepted',
    updated_at = now()
  where id = selected_ride_id
    and passenger_id = auth.uid()
    and status = 'pending';

  if not found then
    raise exception 'ride is no longer available';
  end if;

  update public.ride_offers
  set
    status = case
      when id = p_offer_id then 'accepted'
      else 'rejected'
    end,
    updated_at = now()
  where ride_id = selected_ride_id;

  return true;
end;
$$;

revoke all on function public.create_ride_request(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  integer,
  numeric,
  text
) from public;

revoke all on function public.driver_list_pending_rides() from public;
revoke all on function public.submit_ride_offer(uuid, numeric) from public;
revoke all on function public.passenger_list_ride_offers(uuid) from public;
revoke all on function public.accept_ride_offer(uuid) from public;

grant execute on function public.create_ride_request(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  integer,
  numeric,
  text
) to authenticated;

grant execute on function public.driver_list_pending_rides() to authenticated;
grant execute on function public.submit_ride_offer(uuid, numeric) to authenticated;
grant execute on function public.passenger_list_ride_offers(uuid) to authenticated;
grant execute on function public.accept_ride_offer(uuid) to authenticated;
