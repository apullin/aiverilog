#include <string.h>
#include "sv_vpi_user.h"

static int failed;

static void check_type(const char *name, PLI_INT32 expected)
{
      vpiHandle obj = vpi_handle_by_name((PLI_BYTE8 *)name, 0);
      PLI_INT32 actual;

      if (!obj) {
	    vpi_printf("FAILED: cannot find %s\n", name);
	    failed = 1;
	    return;
      }

      actual = vpi_get(vpiType, obj);
      if (actual != expected) {
	    vpi_printf("FAILED: %s has VPI type %d, expected %d\n",
		       name, actual, expected);
	    failed = 1;
      }
}

static int iterator_has(vpiHandle scope, PLI_INT32 type, const char *name)
{
      vpiHandle iter = vpi_iterate(type, scope);
      vpiHandle obj;
      int found = 0;

      if (!iter)
	    return 0;

      while ((obj = vpi_scan(iter))) {
	    const char *obj_name = vpi_get_str(vpiName, obj);
	    if (obj_name && strcmp(obj_name, name) == 0)
		  found = 1;
      }
      return found;
}

static PLI_INT32 check_calltf(PLI_BYTE8 *data)
{
      vpiHandle scope = vpi_handle_by_name((PLI_BYTE8 *)"test", 0);
      vpiHandle partial;
      s_vpi_value value;
      (void)data;

      check_type("test.logic_a", vpiReg);
      check_type("test.logic_b", vpiReg);
      check_type("test.logic_c", vpiReg);
      check_type("test.signed_a", vpiReg);
      check_type("test.partial", vpiReg);
      check_type("test.bit_a", vpiBitVar);
      check_type("test.net_a", vpiNet);

      if (!scope || !iterator_has(scope, vpiReg, "logic_a") ||
	  iterator_has(scope, vpiNet, "logic_a") ||
	  !iterator_has(scope, vpiNet, "net_a")) {
	    vpi_printf("FAILED: VPI iteration did not preserve declaration types\n");
	    failed = 1;
      }

      partial = vpi_handle_by_name((PLI_BYTE8 *)"test.partial", 0);
      if (!partial) {
	    failed = 1;
      } else {
	    value.format = vpiBinStrVal;
	    value.value.str = (PLI_BYTE8 *)"0001";
	    vpi_put_value(partial, &value, 0, vpiNoDelay);
      }

      if (failed)
	    vpi_control(vpiFinish, 1);
      return 0;
}

static void register_check(void)
{
      s_vpi_systf_data tf = {0};
      tf.type = vpiSysTask;
      tf.tfname = "$check_vpi_types";
      tf.calltf = check_calltf;
      vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {
      register_check,
      0
};
