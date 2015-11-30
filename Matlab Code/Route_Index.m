function [route,name] = Route_Index(fname)
if strcmp(fname, 'PSBP_5_Sample_Routes.csv')==1
    name = {'5CDG-SIN','5FRA-ATL','5HKG-BUD','5LHR-MAD','5NBO-AMS'};
    route = linspace(1,5,5);
elseif strcmp(fname,'PSBP_Whole2.csv')==1
    route = [584,995,827,384,272,781,854,451,21,630,437,411];
    name = {'HKG-BUD','NBO-AMS','LHR-MAD','FRA-ATL','CDG-SIN',...
            'LHR-ATL','LHR-YUL','FRA-PVG','AMS-JFK','HKG-YYZ','FRA-MEX','FRA-EZE'};
%     route = [21, 451];
%     name = {'AMS-JFK','FRA-PVG'};
end