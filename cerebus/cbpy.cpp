/*
 * Cerebus Python
 *
 * @date March 9, 2014
 * @author: dashesy
 */

#include "cbpy.h"

int cbpy_version(int nInstance, cbSdkVersion *ver)
{
    cbSdkResult sdkres = cbSdkGetVersion(nInstance, ver);

    return sdkres;
}

int cbpy_open(int nInstance, cbSdkConnectionType conType, cbSdkConnection con)
{
    cbSdkResult sdkres = cbSdkOpen(nInstance, conType, con);

    return sdkres;
}

int cbpy_gettype(int nInstance, cbSdkConnectionType * conType, cbSdkInstrumentType * instType)
{
    cbSdkResult sdkres = cbSdkGetType(nInstance, conType, instType);

    return sdkres;
}

int cbpy_get_trial_config(int nInstance, cbSdkConfigParam * pcfg_param)
{
    cbSdkResult sdkres = cbSdkGetTrialConfig(nInstance, &pcfg_param->bActive,
            &pcfg_param->Begchan,&pcfg_param->Begmask, &pcfg_param->Begval,
            &pcfg_param->Endchan, &pcfg_param->Endmask, &pcfg_param->Endval,
            &pcfg_param->bDouble, &pcfg_param->uWaveforms,
            &pcfg_param->uConts, &pcfg_param->uEvents, &pcfg_param->uComments,
            &pcfg_param->uTrackings,
            &pcfg_param->bAbsolute);

    return sdkres;
}

int cbpy_set_trial_config(int nInstance, const cbSdkConfigParam * pcfg_param)
{
    cbSdkResult sdkres = cbSdkSetTrialConfig(nInstance, pcfg_param->bActive,
            pcfg_param->Begchan,pcfg_param->Begmask, pcfg_param->Begval,
            pcfg_param->Endchan, pcfg_param->Endmask, pcfg_param->Endval,
            pcfg_param->bDouble, pcfg_param->uWaveforms,
            pcfg_param->uConts, pcfg_param->uEvents, pcfg_param->uComments,
            pcfg_param->uTrackings,
            pcfg_param->bAbsolute);

    return sdkres;
}