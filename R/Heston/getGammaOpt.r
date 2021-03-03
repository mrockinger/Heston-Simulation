library(rootSolve)


##### Getting optimal gamma1 for log-price discretization of Andersen (2008) by matching the (un)conditional skewnesses of the true model and the discretization


# Define function that calculates the unconditional skewness of the modified Bates model of Paper 1
skewUC = function(t, lambda, muj, vj, kappa, theta, sigma, rho){
  
  (-3*(2*kappa*rho - sigma)*sigma*(-2*sigma^2 + kappa*sigma*(8*rho - sigma*t) + 4*kappa^2*(-1 + rho*sigma*t))*theta - exp(kappa*t)*(-3*(2*kappa*rho - sigma)*sigma*(-2*sigma^2 + 4*kappa^3*t + kappa*sigma*(8*rho + sigma*t) - 4*kappa^2*(1 + rho*sigma*t))*theta + 12*kappa^5*lambda*t*vj^2 + kappa^5*lambda*t*vj^3) +      2*exp(kappa*t)*kappa^5*lambda*t*log(1 + muj)*(3*vj*(4 + vj) - 6*vj*log(1 + muj) + 4*log(1 + muj)^2))/(exp(kappa*t)*kappa^5*(((-1 + exp(-(kappa*t)))*sigma^2*theta - 4*kappa^2*rho*sigma*t*theta + kappa*sigma*((4 - 4/exp(kappa*t))*rho + sigma*t)*theta + kappa^3*t*(4*theta + lambda*vj*(4 + vj)))/kappa^3 - 4*lambda*t*vj*log(1 + muj) + 4*lambda*t*log(1 + muj)^2)^1.5)
  
}


# Define function that calculates the DISTANCE btw. the unconditional model skewness and the unconditional skewness of the discretization of Andersen
skewUCdist = function(gamma1, tau, kappa, theta, sigma, rho){
  
  t = tau
  
  #zeta2 is defined as the exact skewness of our process
  zeta2 = skewUC(t, lambda = 0, muj = 0, vj = 0, kappa, theta, sigma, rho)
  
  h = 2 * kappa * rho - sigma
  as = (sigma*t*(-12*(-1 + exp(kappa * t))*(-1 + rho^2)*sigma - 6*h^2*rho*t + exp(kappa * t)*h^3*t^2 + 6*h*(-2 + exp(kappa * t)*(2 + 2*kappa*t - rho*sigma*t)))*theta)/
    (16 *exp(kappa * t)*kappa^2)
  bs = (3*(-1 + exp(- kappa *t))*sigma*t*(-8*(-1 + rho^2)*(h + sigma) + 4*h*(2*kappa - rho*sigma)*t +h^3*t^2)*theta)/(16.*kappa^2)
  cs = (3*(1 - exp(- kappa *t))*h*sigma*t^2*(8*kappa - 4*rho*(h + sigma) + h^2*t)*theta)/(16.*kappa^2)
  a = (theta*(t^2*h^2+8 *kappa *t+8 *rho^2-4 *rho *sigma *t)-4* rho *theta *exp(- kappa *t)*(t*h+2 *rho))/(8 *kappa)
  b = (t *theta *h*(exp(- kappa* t)-1)*(t*h+4 *rho))/(4 *kappa)
  c = (t^2 *theta *h^2*(1-exp(- kappa *t)))/(4 *kappa)
  
  
  abs((as + bs * gamma1 + cs * gamma1^2) / (a + b * gamma1 + c * gamma1^2)^(3/2) - zeta2)
  
}

#Define function that searches the ROOT in the DISTANCE from above by changing the gamma1 hyperparameter
get.gamma.skewUC = function(tau, kappa, theta, sigma, rho){
  optimize(skewUCdist, c(0, 1), kappa = kappa, theta = theta, sigma = sigma, rho = rho, tau = tau)$'minimum'
}

#Vectorize
get.gamma.skewUC = Vectorize(get.gamma.skewUC)


# Define function that calculates the ABSOLUTE DISTANCE btw. the CONDITIONAL model skewness and the conditional skewness of Andersens log-price discretization
skewCdist = function(gamma1, mu, kappa, theta, sigma, rho, t, v0){
  
  ekt = exp(kappa * t)
  e2kt = ekt^2
  g1m1 = gamma1 - 1
  k2 = kappa^2
  k3 = kappa^3
  s2 = sigma^2
  s3 = sigma^3
  r2 = rho^2
  tm2v = theta - 2 * v0
  tm3v = theta - 3 * v0
  kt = kappa * t
  st = sigma * t
  ektm1 = ekt - 1
  
  abs(
    
    (sqrt(2)*(-((ektm1*k3*sigma*(2*rho + g1m1*(-2*kappa*rho + sigma)*t)*
                   (g1m1*t*(-(e2kt*(12*kappa - g1m1*s2*t)*theta) + ekt*(-(g1m1*s2*t*(2*theta - 3*v0)) + 12*kappa*tm2v) + g1m1*s2*t*tm3v) - 
                      4*ektm1*g1m1*rho*st*(-1 + g1m1*kt)*(ektm1*theta + 3*v0) + 
                      4*r2*(e2kt*(1 + g1m1*kt*(1 + g1m1*kt))*theta + (1 + kappa*(t - gamma1*t))^2*tm3v + 
                              ekt*((-2 - g1m1*kt*(-1 + 2*g1m1*kt))*theta + 3*(1 + g1m1^2*k2*t^2)*v0))))/
                  ((-4*g1m1*rho*t*(2*rho + g1m1*st)*tm2v + 8*ekt*g1m1*t*(1 + r2 + g1m1*rho*st)*(theta - v0) + 
                      4*ektm1*g1m1^2*kappa*r2*t^2*(ektm1*theta + 2*v0) + (ektm1*(2*rho + g1m1*st)^2*(ektm1*theta + 2*v0))/kappa - 
                      4*e2kt*t*(g1m1*(2 + g1m1*rho*st)*theta + 2*gamma1*(-1 + r2)*v0))/e2kt)^1.5) - 
                
                
                (sigma*(s3*tm3v + 3*e2kt*((-16*k3*rho*(2 + kt) - 8*kappa*rho*s2*(2 + kt)^2 + s3*(5 + 2*kt*(3 + kt)) + 
                                             8*k2*sigma*(2 + 2*kt + r2*(6 + kt*(4 + kt))))*theta + 
                                            (16*k3*rho*(1 + kt) + 8*k2*rho*s2*t*(2 + kt) + s3*(1 - 2*kt*(1 + kt)) - 8*k2*sigma*(2*kt + r2*(2 + kt*(2 + kt))))*v0) + 
                          6*ekt*sigma*(-2*k2*(-1 + rho*st)*tm2v + s2*(theta - v0) + kappa*sigma*(st*tm2v + rho*(-4*theta + 6*v0))) + 
                          2*exp(3 * kappa * t)*(-24*kappa^4*rho*t*theta + s3*(-11*theta + 3*v0) + 3*kappa*s2*(20*rho*theta + st*theta - 6*rho*v0) + 
                                                  12*k3*(4*rho*theta + st*theta + 2*r2*st*theta - 2*rho*v0) - 6*k2*sigma*((5 + 3*rho*(4*rho + st))*theta - 2*(v0 + 2*r2*v0)))))/
                
                ((s2*tm2v + e2kt*(8*k3*t*theta - 8*k2*(theta + rho*st*theta - v0) + s2*(-5*theta + 2*v0) + 2*kappa*sigma*(8*rho*theta + st*theta - 4*rho*v0)) + 
                    4*ekt*(s2*theta - 2*k2*(-1 + rho*st)*(theta - v0) + kappa*sigma*(st*(theta - v0) + 2*rho*(-2*theta + v0))))/(e2kt*k3))^1.5
    ))/(exp(3 * kappa * t)*kappa^5)
    
  )
  
}

# Define function that MINIMIZES the ABSOLUTE DIFFERENCE btw. the CONDITIONAL model skewness and the conditional skewness of Andersens log-price discretization
get.gamma.skewC = function(Delta, mu, kappa, theta, sigma, rho, vt){
  optimize(skewCdist, c(0, 1), mu = mu, kappa = kappa, theta = theta, sigma = sigma, rho = rho, t = Delta, v0 = vt)$'minimum'
}

#Vectorize
get.gamma.skewC = Vectorize(get.gamma.skewC)

# Now get gamma1 from matching the kurtosis, conditional or unconditional

kurtUC = function(kappa, theta, sigma, rho, tau, lambda, muj, vj){
  
  (3*sigma^2*(-4*kappa*rho + sigma)^2*theta*(sigma^2 + 2*kappa*theta) + 
     12*exp(kappa*tau)*sigma*theta*(7*sigma^5 - kappa*sigma^3*(56*rho*sigma - 5*sigma^2*tau + theta) + 
                                      kappa^2*sigma^2*(-40*rho*sigma^2*tau + sigma^3*tau^2 + 8*rho*theta + sigma*(24 + 136*rho^2 + tau*theta)) - 
                                      4*kappa^3*sigma*(24*rho^3*sigma - 3*sigma^2*tau + 4*rho^2*(-6*sigma^2*tau + theta) + 
                                                         2*rho*sigma*(12 + sigma^2*tau^2 + tau*theta)) - 
                                      4*kappa^5*rho*tau*(-8*rho*sigma + 4*rho^2*sigma^2*tau + 4*theta + lambda*vj*(4 + vj)) + 
                                      kappa^4*sigma*(8 - 48*rho*sigma*tau - 64*rho^3*sigma*tau + 4*rho^2*(16 + 5*sigma^2*tau^2 + 4*tau*theta) + 
                                                       tau*(4*theta + lambda*vj*(4 + vj)))) + exp(2*kappa*tau)*(-87*sigma^6*theta + 6*kappa*sigma^4*theta*(116*rho*sigma + 5*sigma^2*tau + theta) + 
                                                                                                                  6*kappa^3*sigma^2*theta*(192*rho^3*sigma + 16*rho^2*(6*sigma^2*tau + theta) + 16*rho*sigma*(12 + tau*theta) + 
                                                                                                                                             sigma^2*tau*(24 + tau*theta)) - 12*kappa^2*sigma^3*theta*(20*rho*sigma^2*tau + 4*rho*theta + sigma*(24 + 140*rho^2 + tau*theta)) - 
                                                                                                                  48*kappa^6*rho*sigma*tau^2*theta*(4*theta + lambda*vj*(4 + vj)) - 
                                                                                                                  12*kappa^4*sigma^2*theta*(8 + 32*rho^3*sigma*tau + 16*rho^2*(4 + tau*theta) + 4*rho*sigma*tau*(12 + tau*theta) + 
                                                                                                                                              tau*(4*theta + lambda*vj*(4 + vj))) + 2*kappa^7*tau*(lambda*vj^2*(48 + 24*vj + vj^2) + 3*tau*(4*theta + lambda*vj*(4 + vj))^2) + 
                                                                                                                  12*kappa^5*sigma*tau*theta*(4*rho*(4*theta + lambda*vj*(4 + vj)) + sigma*(8 + 8*rho^2*(4 + tau*theta) + tau*(4*theta + lambda*vj*(4 + vj))))) - 
     16*exp(kappa*tau)*kappa^4*lambda*tau*vj*(-3*(-1 + exp(kappa*tau))*sigma^2*theta - 12*exp(kappa*tau)*kappa^2*rho*sigma*tau*theta + 
                                                3*kappa*sigma*(4*(-1 + exp(kappa*tau))*rho + exp(kappa*tau)*sigma*tau)*theta + exp(kappa*tau)*kappa^3*(vj*(12 + vj) + 3*tau*(4*theta + lambda*vj*(4 + vj)))
     )*log(1 + muj) + 48*exp(kappa*tau)*kappa^4*lambda*tau*
     ((1 - exp(kappa*tau))*sigma^2*theta - 4*exp(kappa*tau)*kappa^2*rho*sigma*tau*theta + 
        kappa*sigma*(4*(-1 + exp(kappa*tau))*rho + exp(kappa*tau)*sigma*tau)*theta + exp(kappa*tau)*kappa^3*(vj*(4 + vj) + tau*(4*theta + lambda*vj*(4 + 3*vj))))*
     log(1 + muj)^2 - 64*exp(2*kappa*tau)*kappa^7*lambda*tau*(1 + 3*lambda*tau)*vj*log(1 + muj)^3 + 
     32*exp(2*kappa*tau)*kappa^7*lambda*tau*(1 + 3*lambda*tau)*log(1 + muj)^4)/
    (2*exp(2*kappa*tau)*kappa^7*(((-1 + exp(-kappa*tau))*sigma^2*theta - 4*kappa^2*rho*sigma*tau*theta + 
                                    kappa*sigma*((4 - 4/exp(kappa*tau))*rho + sigma*tau)*theta + kappa^3*tau*(4*theta + lambda*vj*(4 + vj)))/kappa^3 - 4*lambda*tau*vj*log(1 + muj) + 
                                   4*lambda*tau*log(1 + muj)^2)^2)
  
} 


kurtUCdist = function(kappa, theta, sigma, rho, tau, gamma1){
  
  zeta3 = kurtUC(kappa, theta, sigma, rho, tau, lambda = 0, muj = 0, vj = 0)
  
  Power = function(x,y) x^y
  E = exp(1)
  
  t = tau
  
  h = 2 * kappa * rho - sigma
  ak = (3*theta*(8*rho*(2*rho + h*t)^2*(rho*sigma^2 + (h + sigma)*theta) - 4*exp(kappa*t)*
                   (2*sigma^2*(8*rho^4 + 4*rho*(h + h*rho^2 + sigma - rho^2*sigma)*t + 4*h*(h + sigma - rho^2*sigma)*t^2 + h^3*rho*t^3) + 
                      (h + sigma)*(16*rho^3 + 8*(h + h*rho^2 + sigma - rho^2*sigma)*t + 2*h*(4*kappa + rho*(h - 2*sigma))*t^2 + h^3*t^3)*theta) + 
                   exp(2*kappa*t)*(sigma^2*(32*rho^4 + 32*rho*(h + sigma - rho^2*sigma)*t + 8*(2*h^2 + 4*kappa^2 - 2*h*Power(rho,2)*sigma + (-2 + Power(rho,2))*Power(sigma,2))*Power(t,2) + 
                                              8*Power(h,2)*(2*kappa - rho*sigma)*Power(t,3) + Power(h,4)*Power(t,4)) + (32*Power(rho,3)*(h + sigma) + 32*(h + sigma)*(h + sigma - Power(rho,2)*sigma)*t + 
                                                                                                                          8*(8*Power(kappa,3) - 4*kappa*sigma*(h + sigma) + rho*(h + sigma)*(Power(h,2) + Power(sigma,2)))*Power(t,2) - 4*Power(h,2)*(-4*Power(kappa,2) + sigma*(h + sigma))*Power(t,3) + Power(h,4)*kappa*Power(t,4))*theta)
  ))/(64.*Power(E,2*kappa*t)*Power(kappa,3))
  bk = (-3*(-1 + Power(E,kappa*t))*t*theta*(-2*h*(2*rho + h*t)*(4*rho + h*t)*(rho*Power(sigma,2) + (h + sigma)*theta) + 
                                              Power(E,kappa*t)*(Power(sigma,2)*(4*(4*Power(kappa,2) + (-2 + Power(rho,2))*Power(sigma,2))*t + Power(h,4)*Power(t,3) + 8*h*Power(rho,2)*(2*rho - sigma*t) + 2*Power(h,2)*t*(4 + 6*kappa*t - 3*rho*sigma*t)) + 
                                                                  h*(16*Power(rho,2)*(h + sigma) + 4*(4*kappa + rho*(h - 2*sigma))*(h + sigma)*t + 2*h*(Power(h,2) + 4*Power(kappa,2) - Power(sigma,2))*Power(t,2) + Power(h,3)*kappa*Power(t,3))*theta)))/
    (16.*Power(E,2*kappa*t)*Power(kappa,3))
  ck = (3*(-1 + Power(E,kappa*t))*Power(t,2)*theta*(Power(E,kappa*t)*(Power(sigma,2)*(32*Power(kappa,2) + 16*h*(-2 + Power(rho,2))*sigma + 8*(-2 + Power(rho,2))*Power(sigma,2) + 3*Power(h,4)*Power(t,2) + 
                                                                                        4*Power(h,2)*(-4 + 8*Power(rho,2) + 6*kappa*t - 3*rho*sigma*t)) + 4*Power(h,2)*(6*rho*(h + sigma) + (4*Power(kappa,2) + (2*h - sigma)*(h + sigma))*t + Power(h,2)*kappa*Power(t,2))*theta) + 
                                                      Power(h,2)*(-24*Power(rho,2)*Power(sigma,2) - 12*rho*(h*Power(sigma,2)*t + 2*(h + sigma)*theta) - h*t*(h*Power(sigma,2)*t + 2*(6*(h + sigma) + h*kappa*t)*theta))))/(32.*Power(E,2*kappa*t)*Power(kappa,3))
  dk = (-3*Power(-1 + Power(E,kappa*t),2)*Power(h,3)*Power(t,3)*theta*(Power(sigma,2)*(4*rho + h*t) + 2*(2*(h + sigma) + h*kappa*t)*theta))/(16.*Power(E,2*kappa*t)*Power(kappa,3))
  ek = (3*Power(-1 + Power(E,kappa*t),2)*Power(h,4)*Power(t,4)*theta*(Power(sigma,2) + 2*kappa*theta))/(32.*Power(E,2*kappa*t)*Power(kappa,3))
  a = (theta*(t^2*h^2+8 *kappa *t+8 *rho^2-4 *rho *sigma *t)-4* rho *theta *exp(- kappa *t)*(t*h+2 *rho))/(8 *kappa)
  b = (t *theta *h*(exp(- kappa* t)-1)*(t*h+4 *rho))/(4 *kappa)
  c = (t^2 *theta *h^2*(1-exp(- kappa *t)))/(4 *kappa)
  
  abs((ak + bk * gamma1 + ck * gamma1^2 + dk * gamma1^3 + ek * gamma1^4) / (a + b*gamma1 + c*gamma1^2)^2 - zeta3)
  
}  

get.gamma.kurtUC = function(kappa, theta, sigma, rho, tau){
  optimize(kurtUCdist, c(0, 1), kappa = kappa, theta = theta, sigma = sigma, rho = rho, tau = tau)$'minimum'
}

#Vectorize for plotting purposes
get.gamma.kurtUC = Vectorize(get.gamma.kurtUC)



kurtCdist = function(gamma1, mu, kappa, theta, sigma, rho, t, v0){
  
  Power = function(x,y) x^y
  E = exp(1)
  Sqrt = function(x) sqrt(x)
  
  abs(
    
    -(16*Power(t,4)*Power(mu - (kappa*rho*theta)/sigma,4) + 32*Power(t,3)*Power(mu - (kappa*rho*theta)/sigma,2)*
        (-3*gamma1*(-1 + Power(rho,2)) - ((gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/Power(sigma,2))*v0 + 
        48*Power(t,2)*(Power(gamma1,2)*Power(-1 + Power(rho,2),2) + (Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),2)*Power(mu*sigma - kappa*rho*theta,2))/(2.*Power(sigma,4)) + 
                         (2*gamma1*(-1 + Power(rho,2))*(-(gamma1*sigma*t) + 2*rho*(-1 + gamma1*kappa*t))*(-(mu*sigma) + kappa*rho*theta))/Power(sigma,2))*Power(v0,2) + 
        (8*t*Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),2)*(-3*gamma1*(-1 + Power(rho,2)) - ((gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/Power(sigma,2))*Power(v0,3))/Power(sigma,2) + 
        (Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),4)*Power(v0,4))/Power(sigma,4) + 
        (16*((-1 + Power(E,kappa*t))*theta + v0)*((6*(-1 + gamma1)*(-1 + Power(rho,2))*Power(t,3)*Power(mu*sigma - kappa*rho*theta,2))/Power(sigma,2) + 
                                                    (2*Power(t,3)*((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*Power(mu*sigma - kappa*rho*theta,3))/Power(sigma,4) + 
                                                    6*Power(t,2)*(-((-1 + gamma1)*gamma1*Power(-1 + Power(rho,2),2)) - (((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*Power(mu*sigma - kappa*rho*theta,2))/
                                                                    (2.*Power(sigma,4)) - (gamma1*(-1 + Power(rho,2))*(-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(-(mu*sigma) + kappa*rho*theta))/Power(sigma,2) - 
                                                                    ((-1 + gamma1)*(-1 + Power(rho,2))*(-(gamma1*sigma*t) + 2*rho*(-1 + gamma1*kappa*t))*(-(mu*sigma) + kappa*rho*theta))/Power(sigma,2))*v0 - 
                                                    (3*t*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(2*gamma1*(-1 + Power(rho,2))*Power(sigma,2)*(-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t)) + 
                                                                                                          (-1 + gamma1)*(-1 + Power(rho,2))*Power(sigma,2)*(-(gamma1*sigma*t) + 2*rho*(-1 + gamma1*kappa*t)) - 
                                                                                                          ((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))*Power(v0,2))/(2.*Power(sigma,4)) - 
                                                    (((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),3)*Power(v0,3))/(4.*Power(sigma,4))))/Power(E,kappa*t) + 
        (8*(3*Power(-1 + gamma1,2)*Power(-1 + Power(rho,2),2)*Power(t,2) + (3*Power(t,2)*Power((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t),2)*Power(mu*sigma - kappa*rho*theta,2))/(2.*Power(sigma,4)) + 
              (6*(-1 + gamma1)*(-1 + Power(rho,2))*Power(t,2)*(-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(-(mu*sigma) + kappa*rho*theta))/Power(sigma,2) + 
              6*t*(((-1 + gamma1)*t)/2. + (rho*(1 + kappa*(t - gamma1*t)))/sigma)*(((-1 + gamma1)*(-1 + Power(rho,2))*(-(gamma1*sigma*t) + 2*rho*(-1 + gamma1*kappa*t)))/sigma + 
                                                                                     gamma1*(1 - Power(rho,2))*(((-1 + gamma1)*t)/2. + (rho*(1 + kappa*(t - gamma1*t)))/sigma) - 
                                                                                     (((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/(2.*Power(sigma,3)))*v0 + 
              (3*Power((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t),2)*Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),2)*Power(v0,2))/(8.*Power(sigma,4)))*
           (2*kappa*Power((-1 + Power(E,kappa*t))*theta + v0,2) + (-1 + Power(E,kappa*t))*Power(sigma,2)*((-1 + Power(E,kappa*t))*theta + 2*v0)))/(Power(E,2*kappa*t)*kappa) + 
        (4*Power(((-1 + gamma1)*t)/2. + (rho*(1 + kappa*(t - gamma1*t)))/sigma,4)*((12*Power(-1 + Power(E,kappa*t),2)*(3*Power(sigma,4) + 5*kappa*Power(sigma,2)*theta + 2*Power(kappa,2)*Power(theta,2))*Power(v0,2))/
                                                                                     Power(kappa,2) + (8*(-1 + Power(E,kappa*t))*(3*Power(sigma,2) + 2*kappa*theta)*Power(v0,3))/kappa + 4*Power(v0,4) + 
                                                                                     (Power(-1 + Power(E,kappa*t),3)*(3*Power(sigma,6) + 11*kappa*Power(sigma,4)*theta + 12*Power(kappa,2)*Power(sigma,2)*Power(theta,2) + 4*Power(kappa,3)*Power(theta,3))*((-1 + Power(E,kappa*t))*theta + 4*v0))/
                                                                                     Power(kappa,3)))/Power(E,4*kappa*t) - (2*Power((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t),2)*
                                                                                                                              ((6*(-1 + Power(E,kappa*t))*(Power(sigma,2) + kappa*theta)*Power(v0,2))/kappa + 2*Power(v0,3) + 
                                                                                                                                 (Power(-1 + Power(E,kappa*t),2)*(Power(sigma,4) + 3*kappa*Power(sigma,2)*theta + 2*Power(kappa,2)*Power(theta,2))*((-1 + Power(E,kappa*t))*theta + 3*v0))/Power(kappa,2))*
                                                                                                                              (2*mu*sigma*t*(-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t)) + (-1 + gamma1)*Power(sigma,2)*t*(6 - 6*Power(rho,2) + gamma1*t*v0) + 
                                                                                                                                 2*rho*sigma*t*((-1 + 2*gamma1)*v0 + (-1 + gamma1)*kappa*t*(theta - 2*gamma1*v0)) - 4*Power(rho,2)*(-1 + (-1 + gamma1)*kappa*t)*(v0 + kappa*t*(theta - gamma1*v0))))/(Power(E,3*kappa*t)*Power(sigma,4)) + 
        (24*(Power(t,2)*Power(mu - (kappa*rho*theta)/sigma,2) + (-(gamma1*(-1 + Power(rho,2))*t) - (t*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/Power(sigma,2))*v0 + 
               (Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),2)*Power(v0,2))/(4.*Power(sigma,2)) + 
               (((-1 + Power(E,kappa*t))*theta + v0)*((-1 + gamma1)*(-1 + Power(rho,2))*t + (t*((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(mu*sigma - kappa*rho*theta))/Power(sigma,2) - 
                                                        (((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*v0)/(2.*Power(sigma,2))))/Power(E,kappa*t) + 
               (Power((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t),2)*(2*kappa*Power((-1 + Power(E,kappa*t))*theta + v0,2) + (-1 + Power(E,kappa*t))*Power(sigma,2)*((-1 + Power(E,kappa*t))*theta + 2*v0)))/
               (8.*Power(E,2*kappa*t)*kappa*Power(sigma,2)))*Power((-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(theta - v0) + 
                                                                     Power(E,kappa*t)*(2*mu*sigma*t - 2*rho*(-1 + gamma1*kappa*t)*(theta - v0) + sigma*t*((-1 + gamma1)*theta - gamma1*v0)),2))/(Power(E,2*kappa*t)*Power(sigma,2)) - 
        (3*Power((-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(theta - v0) + Power(E,kappa*t)*(2*mu*sigma*t - 2*rho*(-1 + gamma1*kappa*t)*(theta - v0) + sigma*t*((-1 + gamma1)*theta - gamma1*v0)),4))/
        (Power(E,4*kappa*t)*Power(sigma,4)) - (32*((-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(theta - v0) + 
                                                     Power(E,kappa*t)*(2*mu*sigma*t - 2*rho*(-1 + gamma1*kappa*t)*(theta - v0) + sigma*t*((-1 + gamma1)*theta - gamma1*v0)))*
                                                 (Power(t,3)*Power(mu - (kappa*rho*theta)/sigma,3) + 3*Power(t,2)*(mu - (kappa*rho*theta)/sigma)*
                                                    (gamma1 - gamma1*Power(rho,2) - ((gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/(2.*Power(sigma,2)))*v0 - 
                                                    (3*t*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(gamma1 - gamma1*Power(rho,2) - ((gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/(2.*Power(sigma,2)))*Power(v0,2))/(2.*sigma) - 
                                                    (Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),3)*Power(v0,3))/(8.*Power(sigma,3)) + 
                                                    (((-1 + Power(E,kappa*t))*theta + v0)*((-3*(-1 + gamma1)*(-1 + Power(rho,2))*Power(t,2)*(-(mu*sigma) + kappa*rho*theta))/sigma + 
                                                                                             3*Power(t,2)*(((-1 + gamma1)*t)/2. + (rho*(1 + kappa*(t - gamma1*t)))/sigma)*Power(mu - (kappa*rho*theta)/sigma,2) + 
                                                                                             3*t*(((-1 + gamma1)*(-1 + Power(rho,2))*(-(gamma1*sigma*t) + 2*rho*(-1 + gamma1*kappa*t)))/(2.*sigma) + gamma1*(1 - Power(rho,2))*(((-1 + gamma1)*t)/2. + (rho*(1 + kappa*(t - gamma1*t)))/sigma) - 
                                                                                                    (((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/(2.*Power(sigma,3)))*v0 + 
                                                                                             (3*((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),2)*Power(v0,2))/(8.*Power(sigma,3))))/Power(E,kappa*t) + 
                                                    (Power(((-1 + gamma1)*t)/2. + (rho*(1 + kappa*(t - gamma1*t)))/sigma,3)*((6*(-1 + Power(E,kappa*t))*(Power(sigma,2) + kappa*theta)*Power(v0,2))/kappa + 2*Power(v0,3) + 
                                                                                                                               (Power(-1 + Power(E,kappa*t),2)*(Power(sigma,4) + 3*kappa*Power(sigma,2)*theta + 2*Power(kappa,2)*Power(theta,2))*((-1 + Power(E,kappa*t))*theta + 3*v0))/Power(kappa,2)))/(2.*Power(E,3*kappa*t)) + 
                                                    (3*(-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(2*kappa*Power((-1 + Power(E,kappa*t))*theta + v0,2) + (-1 + Power(E,kappa*t))*Power(sigma,2)*((-1 + Power(E,kappa*t))*theta + 2*v0))*
                                                       (2*mu*sigma*t*(-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t)) + (-1 + gamma1)*Power(sigma,2)*t*(4 - 4*Power(rho,2) + gamma1*t*v0) + 
                                                          2*rho*sigma*t*((-1 + 2*gamma1)*v0 + (-1 + gamma1)*kappa*t*(theta - 2*gamma1*v0)) - 4*Power(rho,2)*(-1 + (-1 + gamma1)*kappa*t)*(v0 + kappa*t*(theta - gamma1*v0))))/(16.*Power(E,2*kappa*t)*kappa*Power(sigma,3))
                                                 ))/(Power(E,kappa*t)*sigma))/(16.*Power(Power(t,2)*Power(mu - (kappa*rho*theta)/sigma,2) + 
                                                                                           (-(gamma1*(-1 + Power(rho,2))*t) - (t*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*(mu*sigma - kappa*rho*theta))/Power(sigma,2))*v0 + 
                                                                                           (Power(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t),2)*Power(v0,2))/(4.*Power(sigma,2)) + 
                                                                                           (((-1 + Power(E,kappa*t))*theta + v0)*((-1 + gamma1)*(-1 + Power(rho,2))*t + (t*((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(mu*sigma - kappa*rho*theta))/Power(sigma,2) - 
                                                                                                                                    (((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t))*(gamma1*sigma*t + rho*(2 - 2*gamma1*kappa*t))*v0)/(2.*Power(sigma,2))))/Power(E,kappa*t) + 
                                                                                           (Power((-1 + gamma1)*sigma*t + rho*(2 - 2*(-1 + gamma1)*kappa*t),2)*(2*kappa*Power((-1 + Power(E,kappa*t))*theta + v0,2) + (-1 + Power(E,kappa*t))*Power(sigma,2)*((-1 + Power(E,kappa*t))*theta + 2*v0)))/
                                                                                           (8.*Power(E,2*kappa*t)*kappa*Power(sigma,2)) - Power((-((-1 + gamma1)*sigma*t) + 2*rho*(-1 + (-1 + gamma1)*kappa*t))*(theta - v0) + 
                                                                                                                                                  Power(E,kappa*t)*(2*mu*sigma*t - 2*rho*(-1 + gamma1*kappa*t)*(theta - v0) + sigma*t*((-1 + gamma1)*theta - gamma1*v0)),2)/(4.*Power(E,2*kappa*t)*Power(sigma,2)),2)) + 
      (3*Power(sigma,4)*(Power(sigma,2)*(theta - 4*v0) + kappa*Power(theta - 2*v0,2)) + 24*Power(E,kappa*t)*Power(sigma,2)*
         (Power(sigma,4)*(theta - 2*v0) - 2*Power(kappa,3)*(-1 + rho*sigma*t)*(Power(theta,2) - 3*theta*v0 + 2*Power(v0,2)) + 
            kappa*Power(sigma,2)*(Power(sigma,2)*t*(theta - 3*v0) + theta*(theta - 2*v0) + rho*sigma*(-4*theta + 10*v0)) + 
            Power(kappa,2)*sigma*(-2*rho*Power(sigma,2)*t*(theta - 3*v0) - 2*rho*(2*Power(theta,2) - 5*theta*v0 + 2*Power(v0,2)) + sigma*(t*Power(theta,2) + theta*(2 - 3*t*v0) + 2*v0*(-3 + t*v0)))) + 
         6*Power(E,2*kappa*t)*(2*Power(sigma,6)*(7*theta - 4*v0) + 32*Power(kappa,5)*Power(-1 + rho*sigma*t,2)*Power(theta - v0,2) + 
                                 kappa*Power(sigma,4)*(3*Power(theta,2) + 4*Power(sigma,2)*t*(5*theta - 6*v0) + 12*theta*v0 - 4*Power(v0,2) + rho*sigma*(-96*theta + 80*v0)) + 
                                 2*Power(kappa,2)*Power(sigma,3)*(4*Power(sigma,3)*Power(t,2)*(theta - 2*v0) + 8*rho*Power(sigma,2)*t*(-7*theta + 10*v0) - 4*rho*(6*Power(theta,2) + theta*v0 - 2*Power(v0,2)) + 
                                                                    sigma*(9*t*Power(theta,2) - 24*(v0 + 4*Power(rho,2)*v0) + 2*theta*(12 + 40*Power(rho,2) - 5*t*v0))) + 
                                 8*Power(kappa,3)*Power(sigma,2)*(3*Power(theta,2) - theta*v0 - 2*Power(v0,2) + 4*Power(rho,2)*(Power(sigma,2)*t*(4*theta - 6*v0) + Power(-2*theta + v0,2)) + 
                                                                    rho*sigma*(-13*t*Power(theta,2) - 2*theta*(8 + 2*Power(sigma,2)*Power(t,2) - 9*t*v0) + 4*v0*(6 + 2*Power(sigma,2)*Power(t,2) - t*v0)) + Power(sigma,2)*t*(t*Power(theta,2) + theta*(6 - 2*t*v0) + v0*(-12 + t*v0))) + 
                                 8*Power(kappa,4)*sigma*(4*Power(rho,2)*Power(sigma,3)*Power(t,2)*(theta - 2*v0) - 8*rho*(2*Power(theta,2) - 3*theta*v0 + Power(v0,2)) - 
                                                           4*rho*Power(sigma,2)*t*(t*Power(theta,2) + theta*(2 - 2*t*v0) + v0*(-4 + t*v0)) + sigma*((5 + 16*Power(rho,2))*t*Power(theta,2) - 2*theta*(-1 + (5 + 12*Power(rho,2))*t*v0) + 4*v0*(-1 + t*(v0 + 2*Power(rho,2)*v0))))
         ) + 3*Power(E,4*kappa*t)*(64*Power(kappa,7)*Power(t,2)*Power(theta,2) + kappa*Power(sigma,4)*(20*Power(sigma,2)*t*theta + 32*rho*sigma*(22*theta - 5*v0) + Power(5*theta - 2*v0,2)) + 
                                     32*Power(kappa,5)*(Power(sigma,2)*t*theta*(2 + t*theta + 2*Power(rho,2)*(4 + t*theta)) + 4*rho*sigma*t*theta*(3*theta - 2*v0) + 2*Power(theta - v0,2)) - 128*Power(kappa,6)*t*theta*(theta + rho*sigma*t*theta - v0) + 
                                     Power(sigma,6)*(-93*theta + 20*v0) + 4*Power(kappa,3)*Power(sigma,2)*(Power(sigma,2)*t*theta*(24 + t*theta) + 64*Power(rho,3)*sigma*(4*theta - v0) + 4*(5*Power(theta,2) - 7*theta*v0 + 2*Power(v0,2)) + 
                                                                                                             16*Power(rho,2)*(6*Power(sigma,2)*t*theta + Power(-2*theta + v0,2)) + 4*rho*sigma*(9*t*Power(theta,2) - 24*v0 + theta*(80 - 4*t*v0))) - 
                                     4*Power(kappa,2)*Power(sigma,3)*(40*rho*Power(sigma,2)*t*theta + 4*rho*(10*Power(theta,2) - 9*theta*v0 + 2*Power(v0,2)) + 
                                                                        sigma*(5*t*Power(theta,2) - 24*(v0 + 4*Power(rho,2)*v0) + theta*(88 + 400*Power(rho,2) - 2*t*v0))) - 
                                     16*Power(kappa,4)*sigma*(2*rho*Power(sigma,2)*t*theta*(12 + 8*Power(rho,2) + t*theta) + 8*rho*(2*Power(theta,2) - 3*theta*v0 + Power(v0,2)) + 
                                                                sigma*((7 + 16*Power(rho,2))*t*Power(theta,2) - 4*(v0 + 4*Power(rho,2)*v0) + theta*(10 - 4*t*v0 - 8*Power(rho,2)*(-6 + t*v0))))) - 
         8*Power(E,3*kappa*t)*(16*Power(kappa,6)*t*(-3*Power(rho,2)*Power(sigma,2)*t + Power(rho,3)*Power(sigma,3)*Power(t,2) - 3*theta + 3*rho*sigma*t*theta)*(theta - v0) - 3*Power(sigma,6)*(7*theta + 2*v0) + 
                                 3*kappa*Power(sigma,4)*(theta*(5*theta - 2*v0) + Power(sigma,2)*t*(-9*theta + v0) + 10*rho*sigma*(6*theta + v0)) - 
                                 3*Power(kappa,2)*Power(sigma,3)*(2*Power(sigma,3)*Power(t,2)*(2*theta - v0) + 14*rho*Power(sigma,2)*t*(-5*theta + v0) + 2*rho*(18*Power(theta,2) - 13*theta*v0 + 2*Power(v0,2)) + 
                                                                    sigma*(-3*t*Power(theta,2) - 2*v0*(-3 + t*v0) + theta*(30 + 160*Power(rho,2) + 7*t*v0))) + 
                                 2*Power(kappa,3)*Power(sigma,2)*(27*Power(theta,2) + 48*Power(rho,3)*sigma*(4*theta - v0) - 33*theta*v0 + 6*Power(v0,2) + Power(sigma,4)*Power(t,3)*(-theta + v0) - 
                                                                    3*Power(sigma,2)*t*(18*theta + t*Power(theta,2) - 6*v0 - t*theta*v0) - 24*Power(rho,2)*(Power(sigma,2)*t*(10*theta - 3*v0) - Power(-2*theta + v0,2)) + 
                                                                    3*rho*sigma*(-5*t*Power(theta,2) - 2*t*v0*(4*Power(sigma,2)*t + 3*v0) + theta*(64 + 14*Power(sigma,2)*Power(t,2) + 17*t*v0))) - 
                                 24*Power(kappa,5)*(Power(rho,2)*Power(sigma,4)*Power(t,3)*(theta - v0) - 2*Power(theta - v0,2) + 2*rho*Power(sigma,3)*Power(t,2)*(-2*(1 + Power(rho,2))*theta + (2 + Power(rho,2))*v0) + 
                                                      2*rho*sigma*t*(-2*Power(theta,2) + Power(v0,2)) + Power(sigma,2)*t*((t + 2*Power(rho,2)*t)*Power(theta,2) - 2*(v0 + 2*Power(rho,2)*v0) + theta*(2 - t*v0 + Power(rho,2)*(8 - 2*t*v0)))) + 
                                 12*Power(kappa,4)*sigma*(rho*Power(sigma,4)*Power(t,3)*(theta - v0) + Power(sigma,3)*Power(t,2)*(-((3 + 14*Power(rho,2))*theta) + (3 + 8*Power(rho,2))*v0) - 8*rho*(2*Power(theta,2) - 3*theta*v0 + Power(v0,2)) + 
                                                            rho*Power(sigma,2)*t*(3*t*Power(theta,2) - 8*(2 + Power(rho,2))*v0 + theta*(32 + 24*Power(rho,2) - 3*t*v0)) - 
                                                            sigma*(t*Power(theta,2) - 2*v0*(t*v0 + 2*Power(rho,2)*(2 + t*v0)) + theta*(4 + 3*t*v0 + 8*Power(rho,2)*(3 + t*v0))))))/
      (kappa*Power(Power(sigma,2)*(theta - 2*v0) + Power(E,2*kappa*t)*(8*Power(kappa,3)*t*theta - 8*Power(kappa,2)*(theta + rho*sigma*t*theta - v0) + Power(sigma,2)*(-5*theta + 2*v0) + 
                                                                         2*kappa*sigma*(8*rho*theta + sigma*t*theta - 4*rho*v0)) + 4*Power(E,kappa*t)*(Power(sigma,2)*theta - 2*Power(kappa,2)*(-1 + rho*sigma*t)*(theta - v0) + 
                                                                                                                                                         kappa*sigma*(-4*rho*theta + sigma*t*theta + 2*rho*v0 - sigma*t*v0)),2))
    
    
  )
  
}

kurtCdist = Vectorize(kurtCdist)

get.gamma.kurtC = function(Delta, mu, kappa, theta, sigma, rho, vt){
  optimize(kurtCdist, c(0, 1), mu = mu, kappa = kappa, theta = theta, sigma = sigma, rho = rho, t = Delta, v0 = vt)$'minimum'
}

get.gamma.kurtC = Vectorize(get.gamma.kurtC)

get.opt.gamma1 = function(Delta, mu, kappa, theta, sigma, rho, vt, target, mode){
  
  if(target == "skew" && mode == "conditional"){
    
    get.gamma.skewC(Delta, mu, kappa, theta, sigma, rho, vt)
    
  }else if(target == "skew" && mode == "unconditional"){
    
    get.gamma.skewUC(tau = Delta, kappa, theta, sigma, rho)
    
  }else if(target == "kurt" && mode == "conditional"){
    
    get.gamma.kurtC(Delta, mu, kappa, theta, sigma, rho, vt)
    
  }else if(target == "kurt" && mode == "unconditional"){
    
    get.gamma.kurtUC(kappa, theta, sigma, rho, tau = Delta)
  
  }  
    
}
