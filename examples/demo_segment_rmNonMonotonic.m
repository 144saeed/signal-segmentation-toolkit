%% DEMO: Remove Non-Monotonic Data (sovs.segment.rmNonMonotonic)
% This script demonstrates how to automatically synchronize and clean
% multiple signals (e.g., time, velocity, pressure) when the primary
% reference (Time) has backward glitches or stalls.
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Create a Glitchy Reference Signal (Time)
% Imagine an encoder that stutters and occasionally reads backwards
time_sensor = linspace(0, 10, 100);

% Inject Stalls (Encoder Stuck)
time_sensor(30:35) = time_sensor(29);

% Inject Backward Flow (Encoder slipped backwards)
time_sensor(70:75) = time_sensor(70:-1:65);

%% 2. Create Associated Data (Synchronous)
% Velocity and Pressure recorded at the exact same moments
velocity = sin(time_sensor) * 10;
pressure = cos(time_sensor) * 5;

%% 3. Use the Function in "Visualization Mode"
% By calling the function with NO output arguments, it will automatically
% analyze the data, print a report to the command window, and generate
% a diagnostic plot showing exactly what is wrong with the sensor.
disp('--- Running Visualization Mode ---');
sovs.segment.rmNonMonotonic(time_sensor);

%% 4. Use the Function in "Processing Mode"
% Now let's actually clean the data. Notice how we pass all three arrays.
% The function will find the bad indices in 'time_sensor' and remove those
% exact rows from velocity and pressure automatically!
disp(' ');
disp('--- Running Processing Mode (Sync Slicing) ---');
[clean_time, clean_vel, clean_pres] = sovs.segment.rmNonMonotonic(time_sensor, velocity, pressure);

fprintf('Original Length: %d\n', length(time_sensor));
fprintf('Cleaned Length : %d\n', length(clean_time));
fprintf('Are arrays synced? Yes (Time=%d, Vel=%d, Pres=%d)\n', ...
    length(clean_time), length(clean_vel), length(clean_pres));