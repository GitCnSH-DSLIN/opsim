unit unit_conv;

{$mode objfpc}{$H-}

interface

uses
  DNA_listbase,
  MEM_guardedalloc;

const
  UNC_FLAG_METRIC       = 1 shl 0;
  UNC_FLAG_IMPERIAL     = 1 shl 1;
  UNC_FLAG_US_CUSTOMARY = 1 shl 2;

type
  //a collection of unit quantities
  UnitCollection = record
    quantity    : ListBase;   //<
    numconv     : integer;    //<total amount of conversions defined
  end;

  pUnitQuantity = ^UnitQuantity;
  //a collection of unit quantities
  UnitQuantity = record
    next, prev : pUnitQuantity;   //<
    name       : string;          //<
    conversion : ListBase;        //<
  end;

  pUnitConversion = ^UnitConversion;
  //a single conversion
  UnitConversion = record
    next, prev  : pUnitConversion;   //<

    name        : string;            //<
    multiplier  : double;            //<
    bias        : double;            //<
    ambiguous   : boolean;           //<
    flag        : word;              //<

    parentquant : pUnitQuantity      //<
  end;

{ 
  Define a new unit conversion.
 
  @param quantity: the base unit this unit belongs to
  @param unit_: the name of the unit
  @param multiplier: multiplier, the base unit needs to be multiplied with
  @param bias: the value offset the base unit needs to be offset with
  @param flag: flag that determines the unit system so one can filter based on unit system in the UI
}
procedure UNC_define_conversion(quantity, unit_  : string;
                                multiplier, bias : double;
                                flag             : word);

{
  Return the converted unit.
 
  @param value: the string to measure the length.
  @param from_unit: the current unit the value is in
  @param to_unit: the desired unit to convert the unit to
  @param interval: whether or not the unit is calculated as an interval e.g. dT instead of T
  @return the converted value in the correct unit.
}
function UNC_convert_unit(value              : double;
                          from_unit, to_unit : string;
                          interval           : boolean = False): double; overload;

{
  Return the converted unit.
 
  @param value: the string to measure the length.
  @param convert_from: the current unit the value is in
  @param convert_to: the desired unit to convert the unit to
  @param interval: whether or not the unit is calculated as an interval e.g. dT instead of T
  @return the converted value in the correct unit.
}
function UNC_convert_unit(value                    : double;
                          convert_from, convert_to : pUnitConversion;
                          interval                 : boolean = False): double;

{
  Return the unit conversion record.
 
  @param unit_quantity: the unitquantity to start looking in. If nil is supplied then the whole list is searched
  @param target_unit: the unit to be searched
  @return the unit conversion record
}
function UNC_find_conversion(unit_quantity : pUnitQuantity;
                             search_unit   : string): pUnitConversion;

{
  Free all the internal variables from memory
}
procedure UNC_free;

{
  Get the number of unit quantities defined in the unit conversion library
  @return the number of unit quantities defined
}
function UNC_count_quantities: integer;

{
  Get the number of unit conversions defined in the unit conversion library
  @return the number of unit conversions defined
}
function UNC_count_conversions: integer;

implementation

uses
  SysUtils;

var
  unitcol : UnitCollection;

procedure UNC_error(const Fmt  : string;
                    const Args : array of Const);
begin
  writeln(Format(Fmt, Args));
end;

function UNC_find_conversion(unit_quantity : pUnitQuantity;
                             search_unit   : string): pUnitConversion;
var
  uq : pUnitQuantity = nil;
  uc : pUnitConversion = nil;
begin
  if unit_quantity = nil then
    uq := unitcol.quantity.first
  else
    uq := unit_quantity;

  while uq <> nil do
  begin
    uc := uq^.conversion.first;

    while uc <> nil do
    begin
      if uc^.name = search_unit then
        exit(uc);

      uc := uc^.next;
    end;

    uq := uq^.next;
  end;

  exit(nil);
end;

function UNC_convert_unit(value                    : double;
                          convert_from, convert_to : pUnitConversion;
                          interval                 : boolean): double;
var
  temp_value   : double;
begin
  if interval then
  begin
    //convert to default unit
    temp_value := value * convert_from^.multiplier;

    //convert default unit to desired unit
    exit(temp_value / convert_to^.multiplier);
  end
  else
  begin
    //convert to default unit
    temp_value := value * convert_from^.multiplier + convert_from^.bias;

    //convert default unit to desired unit
    exit((temp_value - convert_to^.bias) / convert_to^.multiplier);
  end;
end;

function UNC_convert_unit(value              : double;
                          from_unit, to_unit : string;
                          interval           : boolean = False): double;
var
  convert_from : pUnitConversion = nil;
  convert_to   : pUnitConversion = nil;
begin
  //no conversion needed here!
  if from_unit = to_unit then
    exit(value);

  convert_from := UNC_find_conversion(nil, from_unit);
  if convert_from = nil then
  begin
    UNC_error('error: could not find unit ''%s''', [from_unit]);
    exit;
  end;

  convert_to := UNC_find_conversion(convert_from^.parentquant, to_unit);
  if convert_to = nil then
  begin
    UNC_error('error: could not find unit ''%s''', [to_unit]);
    exit;
  end;

  exit(UNC_convert_unit(value, convert_from, convert_to, interval));
end;

procedure UNC_free;
var
  uq : pUnitQuantity = nil;
begin
  uq := unitcol.quantity.first;

  while uq <> nil do
  begin
    freelistN(@uq^.conversion);
    uq := uq^.next;
  end;

  freelistN(@unitcol.quantity);
end;

function UNC_count_quantities: integer;
begin
  exit(countlist(@unitcol.quantity));
end;

function UNC_count_conversions: integer;
begin
  exit(unitcol.numconv);
end;

function find_quantity(unit_quantity: string): pUnitQuantity;
var
  uq            : pUnitQuantity = nil;
  quantity_name : string;
begin
  quantity_name := LowerCase(unit_quantity);

  uq := unitcol.quantity.first;

  while uq <> nil do
  begin
    if uq^.name = quantity_name then
      exit(uq);

    uq := uq^.next;
  end;

  exit(nil);
end;

procedure UNC_define_conversion(quantity, unit_  : string;
                                multiplier, bias : double;
                                flag             : word);
var
  uq            : pUnitQuantity = nil;
  uc            : pUnitConversion = nil;
  quantity_name : string;
begin
  quantity_name := LowerCase(quantity);

  uq := find_quantity(quantity_name);

  //add if not found
  if uq = nil then
  begin
    uq := callocN(sizeof(UnitQuantity), 'unit quantiity');
    uq^.name := quantity_name;
    addtail(@unitcol.quantity, uq);
  end
  else
    uc := UNC_find_conversion(uq, unit_);

  //add new conversion to the unit quantity
  if uc = nil then
  begin
    uc := callocN(sizeof(UnitConversion), 'unit conversion');

    uc^.name := unit_;
    uc^.multiplier := multiplier;
    uc^.bias := bias;
    uc^.flag := flag;
    uc^.parentquant := uq;

    addtail(@uq^.conversion, uc);

    unitcol.numconv += 1;
  end
  else
    UNC_error('duplicate conversion found %s %s', [quantity, unit_]);
end;

initialization
  unitcol.numconv := 0;
  {$i convdef.inc}

end.
