CLASS zcl_demo_testing DEFINITION public.

public section.

interfaces zif_demo_testing_get_data.

aliases get_srvc for
zif_demo_testing_get_data~get_srvc .

aliases get_Data  for zif_demo_testing_get_data~get_data.


methods:

constructor.


private section.


methods: get_yrs_of_srvc importing i_date type sy-datum
                exporting e_srvc type char10
                          e_msgg type string.

ENDCLASS.



CLASS zcl_demo_testing IMPLEMENTATION.
method constructor.

endmethod.
method get_yrs_of_srvc.

if i_Date gt sy-datum.

e_msgg = 'La fecha de contratación no puede estar en el futuro' .

else.

e_srvc = (  SY-DATUM - I_DATE ) / 365.
e_srvc = round(  val = e_srvc dec = 1 ).

endif.

endmethod.
method get_srvc.

data lv_datehire type zempdata_demo-datefire.

clear: e_srvc, e_msgg.

select single datefire  from zempdata_demo
where pernr eq @i_pernr
into @lv_datehire.

if sy-subrc NE 0.
 e_msgg = 'empleado no encontrado'.
 else.
 e_srvc = (  SY-DATUM - lv_datehire ) / 365.
e_srvc = round(  val = e_srvc dec = 1 ).

endif.

endmethod.

method get_data.

 select * from zempdata_demo
 where line EQ @i_line and
       designation eq @i_designation
       into table @e_t_empleado.

*       describe  e_t_empleado lines  e_emct.

       if e_t_empleado is initial.
       e_msgg = 'no existen datos'.
       endif.

endmethod.

ENDCLASS.
