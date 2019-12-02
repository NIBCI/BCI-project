% Installer for the Covariance toolbox


HOME = pwd;

if isunix
    path([HOME,'/covariancetoolbox-master/lib'],path);
    path([HOME,'/covariancetoolbox-master/lib/distance'],path);
    path([HOME,'/covariancetoolbox-master/lib/geodesic'],path);
    path([HOME,'/covariancetoolbox-master/lib/riemann'],path);
    path([HOME,'/covariancetoolbox-master/lib/visu'],path);
    path([HOME,'/covariancetoolbox-master/lib/estimation'],path);
    path([HOME,'/covariancetoolbox-master/lib/mean'],path);
    path([HOME,'/covariancetoolbox-master/lib/simulation'],path);
    path([HOME,'/covariancetoolbox-master/lib/jointdiag'],path);
    path([HOME,'/covariancetoolbox-master/lib/classification'],path);
    path([HOME,'/covariancetoolbox-master/lib/potato'],path);
else
    path([HOME,'\covariancetoolbox-master\lib'],path);
    path([HOME,'\covariancetoolbox-master\lib\distance'],path);
    path([HOME,'\covariancetoolbox-master\lib\geodesic'],path);
    path([HOME,'\covariancetoolbox-master\lib\riemann'],path);
    path([HOME,'\covariancetoolbox-master\lib\visu'],path);
    path([HOME,'\covariancetoolbox-master\lib\estimation'],path);
    path([HOME,'\covariancetoolbox-master\lib\mean'],path);
    path([HOME,'\covariancetoolbox-master\lib\simulation'],path);
    path([HOME,'\covariancetoolbox-master\lib\jointdiag'],path);
    path([HOME,'\covariancetoolbox-master\lib\classification'],path);
    path([HOME,'\covariancetoolbox-master\lib\potato'],path);
end    
disp('Covariance toolbox activated');
