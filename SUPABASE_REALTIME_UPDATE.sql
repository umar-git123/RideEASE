<<<<<<< HEAD
-- Add driver location columns to the rides table
alter table public.rides add column driver_lat double precision;
alter table public.rides add column driver_lng double precision;

-- No new policies needed if existing ones cover 'update' for drivers.
=======
-- Add driver location columns to the rides table
alter table public.rides add column driver_lat double precision;
alter table public.rides add column driver_lng double precision;

-- No new policies needed if existing ones cover 'update' for drivers.
>>>>>>> 64697ae0ec150a7f0afdb7d74fa248eb77e0f73f
