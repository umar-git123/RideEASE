-- Add driver location columns to the rides table
alter table public.rides add column driver_lat double precision;
alter table public.rides add column driver_lng double precision;

-- No new policies needed if existing ones cover 'update' for drivers.
