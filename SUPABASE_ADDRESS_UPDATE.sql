<<<<<<< HEAD
-- Add new columns for enhanced features
alter table public.rides add column if not exists pickup_address text;
alter table public.rides add column if not exists destination_address text;
alter table public.rides add column if not exists driver_lat double precision;
alter table public.rides add column if not exists driver_lng double precision;
alter table public.rides add column if not exists fare double precision;
=======
-- Add new columns for enhanced features
alter table public.rides add column if not exists pickup_address text;
alter table public.rides add column if not exists destination_address text;
alter table public.rides add column if not exists driver_lat double precision;
alter table public.rides add column if not exists driver_lng double precision;
alter table public.rides add column if not exists fare double precision;
>>>>>>> 64697ae0ec150a7f0afdb7d74fa248eb77e0f73f
