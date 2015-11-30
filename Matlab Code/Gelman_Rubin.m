% MCMCGR - Gelman-Rubin R statistic for convergence
% Copyright (c) 1998, Harvard University. Full copyright in the file Copyright
%
% calculates the Gelman-Rubin R statistic for each chain
%
% chain = chain of values from an MCMC run; vertically catenated 
% ng = number of groups to use
% 
% See also: MCMCSUMM


function R = Gelman_Rubin(chain, n_chain) 
    [chain_len, nr] = size(chain) ;
    chain_size = chain_len/n_chain ;
    X = NaN*zeros(chain_size, n_chain, nr);
    gstart = 1 ;
    for ig = 1:n_chain ;
        gend = gstart+chain_size-1 ;
        X(:,ig,:) = chain(gstart:gend,:) ;
        gstart = gend+1 ;
    end
    M = mean(X, 1) ;
    tB = std(M,0,2) ;
    B = chain_size * tB .* tB ; 
    S = std(X,0,1) ;
    S2 = S .* S ;
    W = sum(S2,2) / n_chain ;
    vplus = (chain_size-1)/chain_size*W + B/chain_size ;
    R = vplus./W ;
    R = reshape(R, 1, nr);


