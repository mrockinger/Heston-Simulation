function kurtUn=kurtUnBates(t, mu, kappa, theta, sigma, lambda, muj, vj, rho)

error('kurtUnBates.... there may be a mistake in here. Better use momements and reconstruct')
E=exp(1);
kurtUn=(3*Power(sigma,2)*Power(-4*kappa*rho + sigma,2)*theta*(Power(sigma,2) + 2*kappa*theta) +...
12*Power(E,kappa*t)*sigma*theta*(7*Power(sigma,5) - kappa*Power(sigma,3)*(56*rho*sigma - 5*Power(sigma,2)*t + theta) +...
Power(kappa,2)*Power(sigma,2)*(-40*rho*Power(sigma,2)*t + Power(sigma,3)*Power(t,2) + 8*rho*theta + sigma*(24 + 136*Power(rho,2) + t*theta)) -...
4*Power(kappa,3)*sigma*(24*Power(rho,3)*sigma - 3*Power(sigma,2)*t + 4*Power(rho,2)*(-6*Power(sigma,2)*t + theta) +...
2*rho*sigma*(12 + Power(sigma,2)*Power(t,2) + t*theta)) - 4*Power(kappa,5)*rho*t*(-8*rho*sigma + 4*Power(rho,2)*Power(sigma,2)*t + 4*theta + lambda*vj*(4 + vj)) +...
Power(kappa,4)*sigma*(8 - 48*rho*sigma*t - 64*Power(rho,3)*sigma*t + 4*Power(rho,2)*(16 + 5*Power(sigma,2)*Power(t,2) + 4*t*theta) + t*(4*theta + lambda*vj*(4 + vj)))) +...
Power(E,2*kappa*t)*(-87*Power(sigma,6)*theta + 6*kappa*Power(sigma,4)*theta*(116*rho*sigma + 5*Power(sigma,2)*t + theta) +...
6*Power(kappa,3)*Power(sigma,2)*theta*(192*Power(rho,3)*sigma + 16*Power(rho,2)*(6*Power(sigma,2)*t + theta) + 16*rho*sigma*(12 + t*theta) +...
Power(sigma,2)*t*(24 + t*theta)) - 12*Power(kappa,2)*Power(sigma,3)*theta*(20*rho*Power(sigma,2)*t + 4*rho*theta + sigma*(24 + 140*Power(rho,2) + t*theta)) -...
48*Power(kappa,6)*rho*sigma*Power(t,2)*theta*(4*theta + lambda*vj*(4 + vj)) -...
12*Power(kappa,4)*Power(sigma,2)*theta*(8 + 32*Power(rho,3)*sigma*t + 16*Power(rho,2)*(4 + t*theta) + 4*rho*sigma*t*(12 + t*theta) + t*(4*theta + lambda*vj*(4 + vj))) +...
2*Power(kappa,7)*t*(lambda*Power(vj,2)*(48 + 24*vj + Power(vj,2)) + 3*t*Power(4*theta + lambda*vj*(4 + vj),2)) +...
12*Power(kappa,5)*sigma*t*theta*(4*rho*(4*theta + lambda*vj*(4 + vj)) + sigma*(8 + 8*Power(rho,2)*(4 + t*theta) + t*(4*theta + lambda*vj*(4 + vj))))) -...
16*Power(E,kappa*t)*Power(kappa,4)*lambda*t*vj*(-3*(-1 + Power(E,kappa*t))*Power(sigma,2)*theta - 12*Power(E,kappa*t)*Power(kappa,2)*rho*sigma*t*theta +...
3*kappa*sigma*(4*(-1 + Power(E,kappa*t))*rho + Power(E,kappa*t)*sigma*t)*theta + Power(E,kappa*t)*Power(kappa,3)*(vj*(12 + vj) + 3*t*(4*theta + lambda*vj*(4 + vj))))*...
log(1 + muj) + 48*Power(E,kappa*t)*Power(kappa,4)*lambda*t*((1 - Power(E,kappa*t))*Power(sigma,2)*theta - 4*Power(E,kappa*t)*Power(kappa,2)*rho*sigma*t*theta +...
kappa*sigma*(4*(-1 + Power(E,kappa*t))*rho + Power(E,kappa*t)*sigma*t)*theta + Power(E,kappa*t)*Power(kappa,3)*(vj*(4 + vj) + t*(4*theta + lambda*vj*(4 + 3*vj))))*...
Power(log(1 + muj),2) - 64*Power(E,2*kappa*t)*Power(kappa,7)*lambda*t*(1 + 3*lambda*t)*vj*Power(log(1 + muj),3) +...
32*Power(E,2*kappa*t)*Power(kappa,7)*lambda*t*(1 + 3*lambda*t)*Power(log(1 + muj),4))/...
(2.*Power(E,2*kappa*t)*Power(kappa,7)*Power(((-1 + Power(E,-(kappa*t)))*Power(sigma,2)*theta - 4*Power(kappa,2)*rho*sigma*t*theta +...
kappa*sigma*((4 - 4/Power(E,kappa*t))*rho + sigma*t)*theta + Power(kappa,3)*t*(4*theta + lambda*vj*(4 + vj)))/Power(kappa,3) - 4*lambda*t*vj*log(1 + muj) +...
4*lambda*t*Power(log(1 + muj),2),2));