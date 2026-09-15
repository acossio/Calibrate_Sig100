function [pcLin, r] = PulseCompression(Data, Config, WaterProp)

   N=length(Data.RawEcho1_90kHz_SampleRate);
   Z=Data.RawEcho1_90kHz_DataI+j*Data.RawEcho1_90kHz_DataQ;
   Xmit=Data.RawEcho1_90kHzTx_DataI+j*Data.RawEcho1_90kHzTx_DataQ;
   pcLin=zeros(N,length(real(Z(1,:)))-length(Xmit));
   pcLinMat=zeros(N,length(real(Z(1,:)))+length(real(Xmit))-1);
   for i=1:N
      % pcLin(i,:) = abs(complexConv(Z(i,:),Xmit));
      pcLinMat(i,:) = abs(conv(Z(i,:),Xmit));
   end
   pcLin = pcLinMat(:,[length(real(Xmit)):(end-length(real(Xmit)))]);
   r=0:(length(pcLin(1,:))-1);
   %r=r*750/Config.echo_rawSampleRate1;
   r = r*(WaterProp.soundVel*0.5)/Config.echo_rawSampleRate1;
return


