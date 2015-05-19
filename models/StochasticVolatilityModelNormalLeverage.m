classdef StochasticVolatilityModelNormalLeverage < HiddenMarkovModel
    
    properties(GetAccess = 'public', SetAccess = 'private')
        rho = 0.91;       %Scale parameter for X
        sigma = 1;        %Standard deviation of the X (process)
        beta = 0.5;       %Scale parameter for Y
        steps = 400;     %Number of steps
        cor = 0.7;        %Correlation factor between the innovations
        innov_Y;
        innov_X;
    end
  
    methods

        function this = StochasticVolatilityModelNormalLeverage(rho, sigma, beta, steps, cor)
            this = this@HiddenMarkovModel();
            if nargin == 5
                this.rho = rho;
                this.sigma = sigma;
                this.beta = beta;
                this.steps = steps;
                this.cor = cor;
            end
            generate(this);
        end
 
        function generate(this)
            x = zeros(1, this.steps+1);
            y = zeros(1, this.steps);
            x(1) = randn * sqrt(this.sigma^2/(1-this.rho^2));      

            for i=1:this.steps
                innov_y = randn;
                innov_x = this.cor*innov_y + sqrt(1-this.cor^2)*randn;
                
                this.innov_Y(i) = innov_y;
                this.innov_X(i) = innov_x;
                x(i+1) = this.rho  * x(i)  + this.sigma*innov_x;
                y(i)   = this.beta * exp(0.5*x(i))*innov_y;
            end
            this.x = x(1:this.steps); 
            this.y = y;
        end
    end
end
