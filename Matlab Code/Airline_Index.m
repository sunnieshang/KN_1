function [airline,name] = Airline_Index(fname)
    if strcmp(fname, 'PSBP_5_Sample_Routes.csv')==1
        name = {'5AF','5BA','5CV','5DL','5KL','5LH','5LX','5MP','5QR','5SQ'};
        airline = linspace(1,10,10);
    elseif strcmp(fname,'PSBP_Whole3.csv')==1
        airline = linspace(1,20,20);
        name = {'AA','AC','AF','AY','BA','CV','CX','DL','EY','KA',...
            'KE','KL','LH','LX','MP','OS','QR','SK','SQ','UA'};
    end