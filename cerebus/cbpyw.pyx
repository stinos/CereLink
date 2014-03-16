'''
Created on March 9, 2013

@author: dashesy

Purpose: Python wrapper for cbsdk  

'''

from cbpy cimport *
import numpy as np
cimport numpy as np
cimport cython

def version(instance = 0):
    '''Get library version
    Inputs:
        instance - (optional) library instance number
    Outputs:"
        dictionary with following keys
             major - major API version
             minor - minor API version
             release - release API version
             beta - beta API version (0 if a non-beta)
             protocol_major - major protocol version
             protocol_minor - minor protocol version
             nsp_major - major NSP firmware version
             nsp_minor - minor NSP firmware version
             nsp_release - release NSP firmware version
             nsp_beta - beta NSP firmware version (0 if non-beta))
    '''

    cdef int res
    cdef cbSdkVersion ver
    
    res = cbpy_version(<int>instance, &ver)
    
    if res < 0:
        # Make this raise error classes
        raise RuntimeError("error %d" % res)
    
    ver_dict = {'major':ver.major, 'minor':ver.minor, 'release':ver.release, 'beta':ver.beta,
                'protocol_major':ver.majorp, 'protocol_minor':ver.majorp,
                'nsp_major':ver.nspmajor, 'nsp_minor':ver.nspminor, 'nsp_release':ver.nsprelease, 'nsp_beta':ver.nspbeta
                }
    return res, ver_dict


def open(instance = 0, connection='default', parameter={}):
    '''Open library.
    Inputs:
       connection - connection type, string can be one the following
               'default': tries slave then master connection
               'master': tries master connection (UDP)
               'slave': tries slave connection (needs another master already open)
       parameter - dictionary with following keys (all optional)
               'inst-addr': instrument IPv4 address.
               'inst-port': instrument port number.
               'client-addr': client IPv4 address.
               'client-port': client port number.
               'receive-buffer-size': override default network buffer size (low value may result in drops).
       instance - (optional) library instance number
    Outputs:
        Same as "connection" command output
    '''
    
    cdef int res
    
    wconType = {'default': CBSDKCONNECTION_DEFAULT, 'slave': CBSDKCONNECTION_CENTRAL, 'master': CBSDKCONNECTION_UDP} 
    if not connection in wconType.keys():
        raise RuntimeError("invalid connection %S" % connection)
     
    cdef cbSdkConnectionType conType = wconType[connection]
    cdef cbSdkConnection con
    
    cdef bytes szOutIP = parameter.get('inst-addr', '').encode()
    cdef bytes szInIP  = parameter.get('client-addr', '').encode()
    
    con.szOutIP = szOutIP
    con.nOutPort = parameter.get('inst-port', 51001)
    con.szInIP = szInIP
    con.nInPort = parameter.get('client-port', 51002)
    con.nRecBufSize = parameter.get('receive-buffer-size', 0)
    
    res = cbpy_open(<int>instance, conType, con)

    if res < 0:
        # Make this raise error classes
        raise RuntimeError("error %d" % res)
    
    return res, connection(instance=instance)
    
def connection(instance = 0):
    ''' Get connection type
    Inputs:
       instance - (optional) library instance number
    Outputs:
       dictionary with following keys
           'connection': Final established connection; can be any of:
                          'Default', 'Slave', 'Master', 'Closed', 'Unknown'
           'instrument': Instrument connected to; can be any of:
                          'NSP', 'nPlay', 'Local NSP', 'Remote nPlay', 'Unknown')
    '''
    
    cdef int res
    
    cdef cbSdkConnectionType conType
    cdef cbSdkInstrumentType instType
    
    res = cbpy_gettype(<int>instance, &conType, &instType)

    if res < 0:
        # Make this raise error classes
        raise RuntimeError("error %d" % res)
    
    connections = ["Default", "Slave", "Master", "Closed", "Unknown"]
    instruments = ["NSP", "nPlay", "Local NSP", "Remote nPlay", "Unknown"]

    con_idx = conType
    if con_idx < 0 or con_idx >= len(connections):
        con_idx = len(connections) - 1
    inst_idx = instType 
    if inst_idx < 0 or inst_idx >= len(instruments):
        inst_idx = len(instruments) - 1
        
    return {'connection':connections[con_idx],'instrument':instruments[inst_idx]}

def trial_config(instance=0, reset=True, 
                 buffer_parameter={}, 
                 range_parameter={'continuous_length':cbSdk_CONTINUOUS_DATA_SAMPLES,
                                  'event_length':cbSdk_EVENT_DATA_SAMPLES}):
    '''Configure trial settings.
    Inputs:
       reset - boolean, set True to flush data cache and start collecting data immediately,
               set False to stop collecting data immediately
       buffer_parameter - (optional) dictionary with following keys (all optional)
               'double': boolean, if specified, the data is in double precision format
               'absolute': boolean, if specified event timing is absolute (new polling will not reset time for events)
               'continuous_length': set the number of continuous data to be cached
               'event_length': set the number of events to be cached
               'comment_length': set number of comments to be cached
               'tracking_length': set the number of video tracking events to be cached
       range_parameter - (optional) dictionary with following keys (all optional)
               'begin_channel': integer, channel to start polling if certain value seen
               'begin_mask': integer, channel mask to start polling if certain value seen
               'begin_value': value to start polling
               'end_channel': channel to end polling if certain value seen
               'end_mask': channel mask to end polling if certain value seen
               'end_value': value to end polling
       instance - (optional) library instance number
    Outputs:
       reset - (boolean) if it is reset
    '''    
    
    cdef int res
    cdef cbSdkConfigParam cfg_param
    cfg_param.bActive = reset
    
    res = cbpy_get_trial_config(<int>instance, &cfg_param)
    if res < 0:
        # Make this raise error classes
        raise RuntimeError("error %d" % res)
    
    # retrieve old values
    res = cbpy_get_trial_config(<int>instance, &cfg_param)
    
    cfg_param.bDouble = buffer_parameter.get('double', 0)
    cfg_param.uWaveforms = 0 # does not work ayways
    cfg_param.uConts = buffer_parameter.get('continuous_length', 0)
    cfg_param.uEvents = buffer_parameter.get('event_length', 0)
    cfg_param.uComments = buffer_parameter.get('comment_length', 0)
    cfg_param.uTrackings = buffer_parameter.get('tracking_length', 0)
    cfg_param.bAbsolute = buffer_parameter.get('absolute', 0)
    
    
    cfg_param.Begchan = range_parameter.get('begin_channel', 0)
    cfg_param.Begmask = range_parameter.get('begin_mask', 0)
    cfg_param.Begval = range_parameter.get('begin_value', 0)
    cfg_param.Endchan = range_parameter.get('end_channel', 0)
    cfg_param.Endmask = range_parameter.get('end_mask', 0)
    cfg_param.Endval = range_parameter.get('end_value', 0)
    
    res = cbpy_set_trial_config(<int>instance, &cfg_param)
    if res < 0:
        # Make this raise error classes
        raise RuntimeError("error %d" % res)
    
    return res, reset
    