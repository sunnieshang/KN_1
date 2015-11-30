function post_S=Post_Label_Switching(S)
post_S=S;
[post_S.new_mu,I]=sort(S.mu, 2);
    for i=1:1:size(S.mu,1)
        post_S.new_phi(i,:)=S.phi(i,I(i,:));
    end
end