clear;
pepsi = csvread('Pepsi.csv');
coca = csvread('Coca.csv');

pepsi = pepsi(3000:3500);
coca = coca(3000:3500);

p = polyfit(coca,pepsi,1);
length = size(coca,1);

plot(1:length,pepsi,'b',1:length,p(1)* coca+p(2),'r');

Y = [coca, pepsi];

[h,pValue,stat,cValue,reg] = egcitest(Y,'test',{'t1','t2'});
pValue

a = reg(2).coeff(1);
b = reg(2).coeff(2);
plot(Y*[1;-b]-a);
