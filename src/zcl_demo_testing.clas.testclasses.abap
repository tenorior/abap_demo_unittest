*"* use this source file for your ABAP unit test classes
class lcl_my_constraint definition deferred.
class ltc_demo_unit_test definition deferred.
class zcl_demo_testing definition local friends ltc_demo_unit_test.

class lcl_my_constraint definition.

public section.

interfaces if_constraint.

endclass.

class lcl_my_constraint implementation.
method if_constraint~is_valid.
*--------------------------------------------------------------*
* IMPORTING data_object TYPE data
* RETURNING result TYPE abap_bool
*--------------------------------------------------------------* * Local Variables

    DATA: ld_string TYPE string.
    ld_string = data_object.
    result = abap_false.
    CHECK ld_string CS 'SCARY'.
    CHECK strlen( ld_string ) GT 5.
    CHECK ld_string NS 'FLUFFY'.
    result = abap_true.

endmethod. "if_constraint~is_valid.

  METHOD if_constraint~get_description.
*--------------------------------------------------------------*
* RETURNING result TYPE string_table
*--------------------------------------------------------------*
* Local Variables
    DATA: ld_message TYPE string.
    ld_message = 'Monster is not really that scary'.
    APPEND ld_message TO result.
ENDMETHOD. "IF_CONSTRAINT~get_description
ENDCLASS."My Constraint – Implementation


class ltc_demo_unit_Test definition for testing
risk level harmless
duration short.

public section.

methods _01_srvc_success for testing.
methods _02_srvc_fail for testing.

methods _01_srvc2_success for testing.
methods _02_srvc2_fail for testing.

methods _01_tabla_success for testing.
methods _02_tabla_fail for testing.


private section.

class-data enviroment type ref to if_osql_test_environment.
class-methods: class_setup.
class-methods: class_teardown.

methods:setup.  " this is the first method test to be run, don't have parameters
methods: teardown.

data: mo_cut type ref to zcl_demo_testing,
      mo_test type ref to lcl_my_constraint,
      mt_empleado type standard table of zempdata_demo.


endclass.

class ltc_demo_unit_test implementation.


method class_setup.

enviroment = cl_osql_test_environment=>create(  i_dependency_list = value #(  ( 'ZEMPDATA_DEMO' ) ) ).

endmethod.

method setup.
mo_cut = new #(   ).
mo_test = new #(   ).
mt_empleado = VALUE #(

( pernr  = '5001' datefire  = '20000101' line      = 'LOGISTICS' designation = 'TEST' )
( pernr  = '5002' datefire  = '20000201' line      = 'LOGISTICS' designation = 'TEST' )
( pernr  = '5003' datefire  = '20000301' line      = 'LOGISTICS' designation = 'TEST' )
( pernr  = '5004' datefire  = '20000401' line      = 'LOGISTICS' designation = 'TEST' )
( pernr  = '5005' datefire  = '20000501' line      = 'LOGISTICS' designation = 'TEST')
 ).

 enviroment->insert_test_data(  mt_empleado ).

endmethod.
method teardown.

clear mo_cut.
enviroment->clear_doubles(  ).

endmethod.

method class_teardown.

enviroment->destroy(  ).

endmethod.

method _01_srvc_success.

data: lv_datefire type sy-datum value '20000101',
      lv_srvc type char10,
      lv_string type string.

      mo_cut->get_yrs_of_srvc(  exporting i_date = lv_datefire
                                importing
                                            e_srvc  = lv_srvc
                                            e_msgg  = lv_string ).

      cl_abap_unit_assert=>assert_equals(
      exporting  act = lv_srvc
                 exp = round( val = ( sy-datum - lv_datefire ) / 365 dec = 1 ) ).

    cl_abap_unit_assert=>assert_equals(
      exporting  act = mo_test->if_constraint~is_valid( data_object = lv_datefire )
                 exp = abap_true ).


endmethod.

method _02_srvc_fail.

*Given

data: lv_datefire type sy-datum value '20250101',
      lv_srvc type char10,
      lv_string type string.

     "when

      mo_cut->get_yrs_of_srvc(  exporting i_date = lv_datefire
                                importing
                                            e_srvc  = lv_srvc
                                            e_msgg  = lv_string ).
       "then

      cl_abap_unit_assert=>assert_equals(
      exporting  act = lv_string
                 exp = 'La fecha de contratación no puede estar en el futuro').


endmethod.
method _01_srvc2_success.


data: lv_empleado type zempdata_demo-pernr value '5001',
      lv_srvc type char10,
      lv_string type string,
      lv_date  type sy-datum value '20000101'.

      mo_cut->get_srvc(  exporting i_pernr = lv_empleado
                                importing
                                            e_srvc  = lv_srvc
                                            e_msgg  = lv_string ).

          cl_abap_unit_assert=>assert_equals(
      exporting  act = lv_srvc
                 exp = round( val = ( sy-datum - lv_date ) / 365 dec = 1 ) ).

endmethod.
method _02_srvc2_fail .

data: lv_empleado type zempdata_demo-pernr value '5551',
      lv_srvc type char10,
      lv_string type string.

      mo_cut->get_srvc(  exporting i_pernr = lv_empleado
                                importing
                                            e_srvc  = lv_srvc
                                            e_msgg  = lv_string ).

      cl_abap_unit_assert=>assert_equals(
      exporting  act = lv_string
                 exp = 'empleado no encontrado' ).


endmethod.
method _01_tabla_success .


data: lv_line type zempdata_Demo-line value 'LOGISTICS',
      lv_desig type zempdata_demo-designation value 'TEST',
      lv_empleado type zty_t_empleado,
      lv_string type string,
      lv_c type i,
      lt_empleado_exp type zty_t_empleado.

      lt_empleado_exp = value #(
            ( pernr  = '5001' datefire  = '20000101' line      = 'LOGISTICS' designation = 'TEST' )
            ( pernr  = '5002' datefire  = '20000201' line      = 'LOGISTICS' designation = 'TEST' )
            ( pernr  = '5003' datefire  = '20000301' line      = 'LOGISTICS' designation = 'TEST' )
            ( pernr  = '5004' datefire  = '20000401' line      = 'LOGISTICS' designation = 'TEST' )
            ( pernr  = '5005' datefire  = '20000501' line      = 'LOGISTICS' designation = 'TEST')
             ).

      mo_cut->get_data(  exporting i_line = lv_line
                                   i_designation = lv_desig
                                importing
                                            e_t_empleado = lv_empleado
                                            e_emct = lv_c
                                            e_msgg  = lv_string ).

      cl_abap_unit_assert=>assert_equals(
      exporting  act = lv_empleado
                 exp = lt_empleado_exp ).

endmethod.
method _02_tabla_fail.


data: lv_line type zempdata_Demo-line value 'FINANCIAL',
      lv_desig type zempdata_demo-designation value 'TEST',
      lv_empleado type zty_t_empleado,
      lv_string type string,
      lv_c type i.

*      data(lt_empleado_exp) = value #(
*            ( pernr  = '5001' datefire  = '20000101' line      = 'LOGISTICS' designation = 'TEST' )
*            ( pernr  = '5002' datefire  = '20000201' line      = 'LOGISTICS' designation = 'TEST' )
*            ( pernr  = '5003' datefire  = '20000301' line      = 'LOGISTICS' designation = 'TEST' )
*            ( pernr  = '5004' datefire  = '20000401' line      = 'LOGISTICS' designation = 'TEST' )
*            ( pernr  = '5005' datefire  = '20000501' line      = 'LOGISTICS' designation = 'TEST')
*             ).

      mo_cut->get_data(  exporting i_line = lv_line
                                   i_designation = lv_desig
                                importing
                                            e_t_empleado = lv_empleado
                                            e_emct = lv_c
                                            e_msgg  = lv_string ).

      cl_abap_unit_assert=>assert_equals(
      exporting  act = lv_string
                 exp = 'no existen datos' ).


endmethod.


endclass.

class lcl_helper definition.
private section.

*data: mo_pers_layer type ref to ycl_monster_pers_layer.

endclass.
