/*
 * Copyright (c) 2012-2025 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

# include  "compile.h"
# include  "vpi_priv.h"
# include  "vvp_net_sig.h"
# include  "vvp_cobject.h"
# include  "schedule.h"
#ifdef CHECK_WITH_VALGRIND
# include  "vvp_cleanup.h"
#endif
# include  <cstdio>
# include  <cstdlib>
# include  <cstring>
# include  <cassert>
# include  "ivl_alloc.h"

using namespace std;

__vpiStringVar::__vpiStringVar(__vpiScope*sc, const char*na, vvp_net_t*ne)
: __vpiBaseVar(sc, na, ne)
{
}

int __vpiStringVar::get_type_code(void) const
{ return vpiStringVar; }

int __vpiStringVar::vpi_get(int code)
{
      vvp_fun_signal_string*fun = dynamic_cast<vvp_fun_signal_string*> (get_net()->fun);
      assert(fun);
      string str = fun->get_string();

      switch (code) {
	  case vpiSize:
	      // The vpiSize of a string variable is the number of
	      // bytes (characters) in that string.
	    return str.size();
	  case vpiLeftRange:
	    return 0;
	  case vpiRightRange:
            return str.size() - 1;
	  default:
	    fprintf(stderr, "vpi sorry: property is not implemented");
	    assert(false);
	    return 0;
      }
}

void __vpiStringVar::vpi_get_value(p_vpi_value val)
{
      vvp_fun_signal_string*fun = dynamic_cast<vvp_fun_signal_string*> (get_net()->fun);
      assert(fun);
      string str = fun->get_string();

      if (val->format == vpiStringVal || val->format == vpiObjTypeVal) {
	    char*rbuf = static_cast<char *>(need_result_buf(str.size()+1, RBUF_VAL));
	    strcpy(rbuf, str.c_str());
	    val->format = vpiStringVal;
	    val->value.str = rbuf;
	    return;
      }

      val->format = vpiSuppressVal;
}

static string vec4_to_sv_string(const vvp_vector4_t&vec)
{
      string res;
      unsigned nbytes = (vec.size() + 7) / 8;
      for (unsigned b = nbytes ; b > 0 ; b -= 1) {
	    unsigned base = (b - 1) * 8;
	    unsigned char ch = 0;
	    for (unsigned idx = 0 ; idx < 8 && base + idx < vec.size() ; idx += 1) {
		  if (vec.value(base + idx) == BIT4_1)
			ch |= (1u << idx);
	    }
	    if (ch != 0)
		  res.push_back(static_cast<char>(ch));
      }
      return res;
}

vpiHandle __vpiStringVar::vpi_put_value(p_vpi_value val, int)
{
      vvp_fun_signal_string*fun = dynamic_cast<vvp_fun_signal_string*> (get_net()->fun);
      assert(fun);

      string out;
      switch (val->format) {
	  case vpiStringVal:
	    out = val->value.str ? val->value.str : "";
	    break;
	  case vpiIntVal: {
		vvp_vector4_t vec(32, static_cast<uint64_t>(static_cast<uint32_t>(val->value.integer)));
		out = vec4_to_sv_string(vec);
		break;
	  }
	  case vpiScalarVal: {
		vvp_vector4_t vec(8, BIT4_0);
		if (val->value.scalar == vpi1 || val->value.scalar == vpiH)
		      vec.set_bit(0, BIT4_1);
		out = vec4_to_sv_string(vec);
		break;
	  }
	  case vpiBinStrVal:
	  case vpiOctStrVal:
	  case vpiDecStrVal:
	  case vpiHexStrVal: {
		const char*s = val->value.str ? val->value.str : "";
		size_t slen = strlen(s);
		unsigned wid = slen > 8 ? static_cast<unsigned>(slen * 4) : 32;
		wid = ((wid + 7) / 8) * 8;
		vvp_vector4_t vec(wid, BIT4_0);
		if (val->format == vpiBinStrVal) vpip_bin_str_to_vec4(vec, s);
		else if (val->format == vpiOctStrVal) vpip_oct_str_to_vec4(vec, s);
		else if (val->format == vpiDecStrVal) vpip_dec_str_to_vec4(vec, s);
		else vpip_hex_str_to_vec4(vec, s);
		out = vec4_to_sv_string(vec);
		break;
	  }
	  case vpiVectorVal: {
		unsigned sz = fun->get_string().size() * 8;
		if (sz == 0) sz = 32;
		vvp_vector4_t vec(sz, BIT4_0);
		for (unsigned idx = 0 ; idx < sz ; idx += 1) {
		      uint32_t aval = static_cast<uint32_t>(val->value.vector[idx/32].aval);
		      uint32_t bval = static_cast<uint32_t>(val->value.vector[idx/32].bval);
		      if (((bval >> (idx%32)) & 1u) == 0 && ((aval >> (idx%32)) & 1u) == 1)
			    vec.set_bit(idx, BIT4_1);
		}
		out = vec4_to_sv_string(vec);
		break;
	  }
	  case vpiRealVal: {
		vvp_vector4_t vec(64, val->value.real);
		out = vec4_to_sv_string(vec);
		break;
	  }
	  default:
	    break;
      }

      vvp_net_ptr_t dest (get_net(), 0);
      vvp_send_string(dest, out, vthread_get_wt_context());
      return 0;
}

vpiHandle vpip_make_string_var(const char*name, vvp_net_t*net)
{
      __vpiScope*scope = vpip_peek_current_scope();
      const char*use_name = name ? vpip_name_string(name) : NULL;

      __vpiStringVar*obj = new __vpiStringVar(scope, use_name, net);

      return obj;
}

class __vpiPropStringRef : public __vpiHandle {
    public:
      __vpiPropStringRef(__vpiScope*sc, unsigned pidx)
      : class_net_(0), prop_idx_(pidx), scope_(sc) { }

      int get_type_code(void) const override { return vpiStringVar; }

      vvp_cobject* get_cobj() const
      {
	    if (!class_net_) return 0;
	    const vvp_fun_signal_object*fun =
		  dynamic_cast<vvp_fun_signal_object*>(class_net_->fun);
	    if (!fun) return 0;
	    return fun->get_object().peek<vvp_cobject>();
      }

      int vpi_get(int code) override
      {
#if defined(CHECK_WITH_VALGRIND) && !defined(BR916_STOPGAP_FIX)
	    if (code == _vpiFromThr) return _vpi_at_PS;
#endif
	    vvp_cobject*cobj = get_cobj();
	    string str = cobj ? cobj->get_string(prop_idx_) : string("");
	    switch (code) {
		case vpiSize:
		  return str.size();
		case vpiLeftRange:
		  return 0;
		case vpiRightRange:
		  return str.size() - 1;
		default:
		  return 0;
	    }
      }

      char* vpi_get_str(int code) override
      {
	    if (code == vpiFile)
		  return simple_set_rbuf_str(file_names[0]);
	    return generic_get_str(code, scope_, "prop_string", NULL);
      }

      void vpi_get_value(p_vpi_value val) override
      {
	    vvp_cobject*cobj = get_cobj();
	    string str = cobj ? cobj->get_string(prop_idx_) : string("");
	    if (val->format == vpiStringVal || val->format == vpiObjTypeVal) {
		  char*rbuf = static_cast<char*>(need_result_buf(str.size()+1, RBUF_VAL));
		  strcpy(rbuf, str.c_str());
		  val->format = vpiStringVal;
		  val->value.str = rbuf;
		  return;
	    }
	    val->format = vpiSuppressVal;
      }

      vpiHandle vpi_put_value(p_vpi_value val, int) override
      {
	    vvp_cobject*cobj = get_cobj();
	    if (!cobj) return 0;

	    string out;
	    switch (val->format) {
		case vpiStringVal:
		  out = val->value.str ? val->value.str : "";
		  break;
		case vpiIntVal: {
		      vvp_vector4_t vec(32, static_cast<uint64_t>(static_cast<uint32_t>(val->value.integer)));
		      out = vec4_to_sv_string(vec);
		      break;
		}
		case vpiScalarVal: {
		      vvp_vector4_t vec(8, BIT4_0);
		      if (val->value.scalar == vpi1 || val->value.scalar == vpiH)
			    vec.set_bit(0, BIT4_1);
		      out = vec4_to_sv_string(vec);
		      break;
		}
		case vpiBinStrVal:
		case vpiOctStrVal:
		case vpiDecStrVal:
		case vpiHexStrVal: {
		      const char*s = val->value.str ? val->value.str : "";
		      size_t slen = strlen(s);
		      unsigned wid = slen > 8 ? static_cast<unsigned>(slen * 4) : 32;
		      wid = ((wid + 7) / 8) * 8;
		      vvp_vector4_t vec(wid, BIT4_0);
		      if (val->format == vpiBinStrVal) vpip_bin_str_to_vec4(vec, s);
		      else if (val->format == vpiOctStrVal) vpip_oct_str_to_vec4(vec, s);
		      else if (val->format == vpiDecStrVal) vpip_dec_str_to_vec4(vec, s);
		      else vpip_hex_str_to_vec4(vec, s);
		      out = vec4_to_sv_string(vec);
		      break;
		}
		case vpiVectorVal: {
		      unsigned sz = cobj->get_string(prop_idx_).size() * 8;
		      if (sz == 0) sz = 32;
		      vvp_vector4_t vec(sz, BIT4_0);
		      for (unsigned idx = 0 ; idx < sz ; idx += 1) {
			    uint32_t aval = static_cast<uint32_t>(val->value.vector[idx/32].aval);
			    uint32_t bval = static_cast<uint32_t>(val->value.vector[idx/32].bval);
			    if (((bval >> (idx%32)) & 1u) == 0 && ((aval >> (idx%32)) & 1u) == 1)
				  vec.set_bit(idx, BIT4_1);
		      }
		      out = vec4_to_sv_string(vec);
		      break;
		}
		case vpiRealVal: {
		      vvp_vector4_t vec(64, val->value.real);
		      out = vec4_to_sv_string(vec);
		      break;
		}
		default:
		  break;
	    }

	    cobj->set_string(prop_idx_, out);
	    return 0;
      }

      vvp_net_t*class_net_;
      unsigned prop_idx_;
    private:
      __vpiScope*scope_;
};

vpiHandle vpip_make_prop_string_ref(char*class_label, unsigned prop_idx)
{
      __vpiPropStringRef*obj = new __vpiPropStringRef(vpip_peek_current_scope(),
						      prop_idx);
      functor_ref_lookup(&obj->class_net_, class_label);
      return obj;
}

#ifdef CHECK_WITH_VALGRIND
void string_delete(vpiHandle item)
{
      delete item;
}
#endif
