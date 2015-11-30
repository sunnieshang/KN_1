function y = PieceWise(t)
    y = zeros(size(t));
    D1=3;E1=-6;D2=12;E2=-15;D3=24;E3=-27;D4=36;E4=-39;D5=48;E5=-51;
    C1=0; C2=5; C3=10; C4=30; C5=120; C6=600;
    % First tier: -6~3
    idx1 = E1<=t&t<D1;
    y(idx1) = C1;
    % Second tier: -15~-6 & 3~12
    idx2 = E2<=t&t<E1;
    y(idx2) = C2*(E1-t(idx2));
    idx3 = D1<=t&t<D2;
    y(idx3) = C2*(t(idx3)-D1);
    % Third tier: -27~-15 & 12~24
    idx4 = E3<=t&t<E2;
    y(idx4) = 9*C2+C3*(E2-t(idx4));
    idx5 = D2<=t&t<D3;
    y(idx5) = 9*C2+C3*(t(idx5)-D2);
    % Fourth tier: -36~-27 & 24~36
    idx6 = E4<=t&t<E3;
    y(idx6) = 9*C2+12*C3+C4*(E3-t(idx6));
    idx7 = D3<=t&t<D4;
    y(idx7) = 9*C2+12*C3+C4*(t(idx7)-D3);   
    % Fifth tier: -51~-39 & 36~48
    idx8 = E5<=t&t<E4;
    y(idx8) = 9*C2+12*C3+12*C4+C5*(E4-t(idx8));
    idx9 = D4<=t&t<D5;
    y(idx9) = 9*C2+12*C3+12*C4+C5*(t(idx9)-D4);     
    % Sixth tier: -51~-39 & 36~48
    idx10 = t<E5;
    y(idx10) = 9*C2+12*C3+12*C4+12*C5+C6*(E5-t(idx10));
    idx11 = D5<=t;
    y(idx11) = 9*C2+12*C3+12*C4+12*C5+C6*(t(idx11)-D5);     
end