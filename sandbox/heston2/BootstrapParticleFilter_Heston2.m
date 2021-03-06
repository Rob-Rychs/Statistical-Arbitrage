
function [log_p_y_given_theta, estimated_states] = BootstrapParticleFilter_Heston2(y, alpha, beta, sigma, theta, r, N)
    
    %fprintf('[PF] mu = %f, theta = %f, kappa = %f, zeta = %f\n', mu, theta, kappa, zeta);
    T = length(y);
    p = zeros(N, T);
    w = zeros(N, T);
    estimated_states = zeros(1,T);
    log_p_y_given_theta = zeros(1,T);
    
    p_y_given_x = @(y, mu, sig) normpdf(y, mu, sig);
    
    p(:,1)                  =   rand(N,1) * 10; %positive values
    w(:,1)                  =   (1/N);
    log_p_y_given_theta(1)  =   log(mean(w(:,1)));
    estimated_states(1)     =   (w(:,1) / sum(w(:,1)))'*p(:,1);
    
    deltatime = 1/252;
    
    for t = 2:T

        try
            nIdx = randsample(N, N, 'true', w(:,t-1));
        catch
            nIdx = 1:N;
        end
        
        %kill the negative particles
        p_prev              = p(nIdx,t-1);
        p_prev(p_prev < 0)  = 0;
        
        p(:,t) = p_prev + ( alpha - beta * p_prev) * deltatime + sigma * ((p_prev * deltatime).^.5) .* randn(N,1);
        %p(:,t) = p_prev + kappa*(theta-p_prev) + zeta * sqrt(p_prev) .* randn(N,1);
        
        particles = p(:,t);
        particles(particles < 0) = 1e-99;
        p(:,t) = particles;
        
        %v(i) = v(i-1) + ( alpha - beta * v(i-1)) * deltatime + sigma * ((v(i-1) * deltatime)^.5) * epsilon(2); 
        %s(i) = s(i-1) + ( r- theta) * s(i-1)      * deltatime + s(i-1) * ((v(i-1) * deltatime)^.5) * epsilon(1);
        
        w(:,t)                  = p_y_given_x(y(t), y(t-1) + (r-theta) * y(t-1) * deltatime, ((p(:,t) * deltatime).^.5));
        log_p_y_given_theta(t)  = log_p_y_given_theta(t-1) + log(mean(w(:,t)));
        
        % Calculate state estimate
        norm_w = w(:,t) / sum(w(:,t));
        estimated_states(t) = norm_w'*p(:,t);
    end
    
    log_p_y_given_theta = log_p_y_given_theta(end);
end