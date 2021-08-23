function dt = deltatime3db(fileName)

samples = dlmread(fileName, '\t');

% Find DC-level (assumes 25 first samples are DC-level):
dca = sum(samples(1:25,1))/25;
dcb = sum(samples(1:25,2))/25;

% Find pulse start (defined to be at amplitude 10 above dc-level)
a = find(samples(:,1) > dca + 10);
pstarta = a(1);

b = find(samples(:,2) > dcb + 10);
pstartb = b(1);

% Find pulse end
i = 2;
dx2 = a(2);
dx1 = a(1);
while dx2 == dx1 + 1 & (i < length(a))
    i = i + 1;
    dx1 = dx2;
    dx2 = a(i);
end
penda = a(i-1);

i = 2;
dx2 = b(2);
dx1 = b(1);
while (dx2 == dx1 + 1) & (i < length(b))
    i = i + 1;
    dx1 = dx2;
    dx2 = b(i);
end
pendb = b(i-1);


% Find pulse amplitude (max value)
ampa = max(samples(pstarta:penda,1));
ampb = max(samples(pstartb:pendb,2));

% Find 3dB below amplitude
a3db = (ampa-dca) / (10 ^ (3/10));
b3db = (ampb-dcb) / (10 ^ (3/10));

% Find index of 3dB level
a = find(samples(:,1) > (a3db+dca));
ta = a(1);
b = find(samples(:,2) > (b3db+dcb));
tb = b(1);

% Plot it
figure(1);
clf;
plot(1:length(samples), samples, ta, a3db+dca, 'o', tb, b3db+dcb, '*');
axis([min(tb, ta)-50 max(tb, ta)+100 dcb-25 ampb+25]);

% Calculate delta time in microseconds
dt = (tb - ta) * 0.625

figure(2);
clf;
dd = 343 * dt / 1000 % mm
sl = 130;   % mm
micy = 154;

sx = dd + (sl - dd) / 2;

for index = 1:100
    x(index) = (sx ^ 2 + sl ^ 2 - (sx-dd)^2)/2/sl;
    y(index) = micy - sqrt(abs(sx^2-x(index)^2));
    sx = sx + 1;
end
x = x + 3;

plot(x, y);


x = [0 135 135 0 0 ];
y = [0 0 162 162 0 ];
line(x, y);
x = [0 135];
y = [135 135];
line(x, y);
for index = 127.5:-10:7.5
    x = [0 135];
    y = [index index];
    if index == 67.5 lw = 3;
    else lw = 0.5;
    end
    line(x, y, 'LineWidth', lw);
    line(y, x, 'LineWidth', lw);
end
axis([0 135 0 162]);





