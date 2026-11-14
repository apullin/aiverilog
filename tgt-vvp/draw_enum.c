/*
 * Copyright (c) 2010-2026 Stephen Williams (steve@icarus.com)
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

# include  "vvp_priv.h"
# include  "ivl_alloc.h"
# include  <stdlib.h>
# include  <string.h>
# include  <assert.h>
# include  <inttypes.h>

// HERE: This still needs work! We should pass the file and
//       line number information for the enum type and the MSB and
//       LSB should be used instead of the width.

static void draw_enum4_value(ivl_enumtype_t enumtype, unsigned idx);

/*
 * If it fits we always print this as a uint64_t the run time will turn
 * it back into a signed value when needed. Wider values are printed in
 * the <width>'b format.
 */
static void draw_enum2_value(ivl_enumtype_t enumtype, unsigned idx)
{
      uint64_t val, mask;
      const char*bits = ivl_enum_bits(enumtype, idx);
      const char*bit;
      unsigned len = strlen(bits);

      if (len > sizeof(uint64_t)*8) {
	    draw_enum4_value(enumtype, idx);
	    return;
      }

      val = 0;
      for (bit = bits, mask = 1 ; *bit != 0 ; bit += 1, mask <<= 1) {
	    if (*bit == '1')
		  val |= mask;
      }

      fprintf(vvp_out, "%" PRIu64, val);
}

static void draw_enum4_value(ivl_enumtype_t enumtype, unsigned idx)
{
      const char*bits = ivl_enum_bits(enumtype, idx);
      const char*bit;

      fprintf(vvp_out, "%u'b", ivl_enum_width(enumtype));

      for (bit = bits+strlen(bits) ; bit > bits ; bit -= 1)
	    fputc(bit[-1], vvp_out);

}

void draw_enumeration_in_scope(ivl_enumtype_t enumtype)
{
      unsigned idx;
      unsigned name_count = ivl_enum_names(enumtype);
      const char*dtype = ivl_enum_type(enumtype)==IVL_VT_BOOL? "2" : "4";
      const char*stype = ivl_enum_signed(enumtype) ? "/s" : "";

      fprintf(vvp_out, "enum%p .enum%s%s (%u)\n", enumtype, dtype, stype,
                       ivl_enum_width(enumtype));

      for (idx = 0 ; idx < name_count ; idx += 1) {
	    fprintf(vvp_out, "   \"%s\" ",
		    vvp_mangle_name(ivl_enum_name(enumtype, idx)));

	    switch (ivl_enum_type(enumtype)) {
		case IVL_VT_BOOL:
		  draw_enum2_value(enumtype, idx);
		  break;
		case IVL_VT_LOGIC:
		  draw_enum4_value(enumtype, idx);
		  break;
		default:
		  assert(0);
	    }

	    if ((idx+1) < name_count)
		  fputc(',', vvp_out);
	    fputc('\n', vvp_out);
      }

      fprintf(vvp_out, " ;\n");
}

int draw_enum_cast(ivl_expr_t dest, ivl_expr_t src,
		   ivl_enumtype_t enumtype,
		   int report, int want_result)
{
      int is_prop = ivl_expr_type(dest) == IVL_EX_PROPERTY;
      unsigned enum_wid = ivl_enum_width(enumtype);
      unsigned lab_fail = local_count++;
      unsigned lab_end = local_count++;
      int src_signed = 0;

      if (is_prop)
	    fprintf(vvp_out, "    %%load/obj v%p_0;\n", ivl_expr_signal(dest));

      if (ivl_expr_value(src) == IVL_VT_REAL) {
	    unsigned cvt_wid = enum_wid > 64 ? enum_wid : 64;
	    draw_eval_real(src);
	    fprintf(vvp_out, "    %%cvt/vr %u;\n", cvt_wid);
	    src_signed = 1;
      } else {
	    draw_eval_vec4(src);
	    src_signed = ivl_expr_signed(src) != 0;
      }

      unsigned flags = (report ? 1U : 0U) | (src_signed ? 2U : 0U);
      fprintf(vvp_out, "    %%cast/enum enum%p, %u;\n", enumtype, flags);
      fprintf(vvp_out, "    %%jmp/0 T_%u.%u, 4;\n", thread_count, lab_fail);

      fprintf(vvp_out, "    %%pad/u %u;\n", enum_wid);
      if (ivl_enum_type(enumtype) == IVL_VT_BOOL)
	    fprintf(vvp_out, "    %%cast2;\n");

      if (is_prop) {
	    fprintf(vvp_out, "    %%store/prop/v %d, %u;\n",
		    ivl_expr_property_idx(dest), enum_wid);
	    fprintf(vvp_out, "    %%pop/obj 1, 0;\n");
      } else {
	    ivl_signal_t sig = ivl_expr_signal(dest);
	    ivl_expr_t word_ex = ivl_expr_oper1(dest);
	    if (word_ex) {
		  int w_idx = allocate_word();
		  draw_eval_expr_into_integer(word_ex, w_idx);
		  fprintf(vvp_out, "    %%store/vec4a v%p, %d, 0;\n", sig, w_idx);
		  clr_word(w_idx);
	    } else if (signal_is_return_value(sig)) {
		  fprintf(vvp_out, "    %%ret/vec4 0, 0, %u;\n", enum_wid);
	    } else {
		  fprintf(vvp_out, "    %%store/vec4 v%p_0, 0, %u;\n", sig, enum_wid);
	    }
      }

      if (want_result)
	    fprintf(vvp_out, "    %%pushi/vec4 1, 0, 32;\n");
      fprintf(vvp_out, "    %%jmp T_%u.%u;\n", thread_count, lab_end);

      fprintf(vvp_out, "T_%u.%u ;\n", thread_count, lab_fail);
      fprintf(vvp_out, "    %%pop/vec4 1;\n");
      if (is_prop)
	    fprintf(vvp_out, "    %%pop/obj 1, 0;\n");
      if (want_result)
	    fprintf(vvp_out, "    %%pushi/vec4 0, 0, 32;\n");
      fprintf(vvp_out, "T_%u.%u ;\n", thread_count, lab_end);

      return 0;
}
