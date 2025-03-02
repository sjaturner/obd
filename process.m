load out
out(:,1)-=out(1,1);
retimed=(min(out(:,1)):0.05:max(out(:,1)))';

for index = 2:size(out)(2)
    retimed=[retimed, interp1(out(:,1)', out(:,index)',retimed(:,1)', 'previous')'];
end

time=retimed(:,1);
rpm=retimed(:,2);
speed=retimed(:,3)/1.609344;
throttle=retimed(:,4);
gears=speed./rpm;
plot(retimed(:,1),gears)
pause

changes=gears-shift(gears,35);
plot(retimed(:,1),changes);
pause

function crossings = oneruns(input, threshold)
    rise_indices = find(diff(input) == 1) + 1;
    fall_indices = find(diff(input) == -1) + 1;

    % Handle edge cases, balance rise and fall
    if length(rise_indices) > length(fall_indices)
        rise_indices(end) = [];
    elseif length(fall_indices) > length(rise_indices)
        fall_indices(1) = [];
    end
    crossings = [rise_indices, fall_indices];
end

upshifts=changes > 0.0025;
upshiftsat=oneruns(upshifts);
downshifts=changes < -0.0025;
downshiftsat=oneruns(downshifts);

hold on
plot([retimed(upshiftsat(:,1)),retimed(upshiftsat(:,2))],0.002.*[0 1],'r')
plot([retimed(downshiftsat(:,1)),retimed(downshiftsat(:,2))],0.002.*[0 -1],'g')
pause

ratios=floor(gears*10000);
ratios(isnan(ratios))=1;
ratios(ratios==Inf)=1;
ratios(ratios<1)=1;
distribution=accumarray(ratios,1);
distribution(1:40)=0;
distribution/=(max(distribution)/1000);
clf
stairs(distribution);
pkg load signal
[pks, locs] = findpeaks(distribution, "MinPeakHeight",20,"MinPeakDistance",20)
hold on
plot(locs,pks,'ro')
pause
locs/=1000

function plotter(out)
    clf;hold on;plot(out(:,1),out(:,2),'.b-');plot(out(:,1),out(:,3)/1.609344*100,'.r-');plot(out(:,1),out(:,4)/256*6000,'.g-')
end
