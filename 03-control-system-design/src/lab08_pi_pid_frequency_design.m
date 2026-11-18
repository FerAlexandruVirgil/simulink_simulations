   close;
   clear;clc
%%
   Hf = tf(3.5,[0.5 1 0]);
   Vrp = 0.3423;
   cvp= 1.25; cvpi = 7;
   wt1 = 1.06;
   wz = wt1/10;
   Tz = 1/wz;
   wp = wz*(cvp/cvpi);
   Tp = 1/wp;
   Vrpi = Vrp * (cvpi / cvp);
   Hc = tf([Vrpi*Tz Vrpi], [Tp 1]);
   Ho = feedback(series(Hc,Hf),1);

   t = 0:0.1:50;

   figure
   step(Ho);

   figure
   lsim(Ho,t,t);
   title("lsim Ho");

   figure
   bode(Ho);
   title("H inchis");

   r = t;
   y = lsim(Ho,t,t);
   estp = r(end) - y(end);
   cv = 1/estp;
   %%
   Hf = tf(3.5,[0.5 1 0]);
   tsp = 3.88; tspid = 0.7;
   cvp = 1.25; cvpid = 7;
   Vrp = 0.3423;
   wt1 = 1.06;
   tspd = 2;
   t = 0:0.1:50;
   wz = wt1/10;
   Tz = 1/wz;
   wp = wz*(cvp/cvpid);
   Tp = 1/wp;
   Td = 0.5;
   Tn = Td*(tspid/tsp);
   Vrpid = Vrp * (cvpid/cvp)*(tsp /tspid);
   Hc1 = tf([Vrpid*Tz Vrpid], [Tp 1]); Hc2 = tf([Td 1], [Tn 1]); Hc = series(Hc1,Hc2);
   Ho = feedback(series(Hc,Hf),1);

   figure
   step(Ho);

   figure
   lsim(Ho,t,t);
   title("lsim Ho");

   figure
   bode(Ho);
   title("H inchis");

   r = t;
   y = lsim(Ho,t,t);
   estp = r(end) - y(end);
   cv = 1/estp;

