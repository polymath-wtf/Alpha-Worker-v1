from sageattn3 import sageattn3_blackwell as _sa3

def sageattn(q, k, v, is_causal=False, attn_mask=None, tensor_layout="NHD", **kwargs):
    call_kwargs = {'is_causal': is_causal}
    if attn_mask is not None:
        call_kwargs['attn_mask'] = attn_mask
    
    if 'sm_scale' in kwargs:
        call_kwargs['sm_scale'] = kwargs['sm_scale']

    if tensor_layout == "NHD":
        q, k, v = q.transpose(1, 2), k.transpose(1, 2), v.transpose(1, 2)
        out = _sa3(q, k, v, **call_kwargs)
        return out.transpose(1, 2)
        
    return _sa3(q, k, v, **call_kwargs)

sageattn_qk_int8_pv_fp16_cuda = sageattn
sageattn_qk_int8_pv_fp8_cuda = sageattn
sageattn_qk_int8_pv_fp16_triton = sageattn
__version__ = "3.0.0-shim"