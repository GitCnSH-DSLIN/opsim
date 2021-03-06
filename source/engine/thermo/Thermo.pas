{ $Id$ }
{
 /***************************************************************************

                  Abstract: Definition of fundamental thermo classes.
                  Initial Revision : 05/04/2006
                  Authors:
                    - Samuel Jorge Marques Cartaxo
                    - Hazem Haddad
                    - Additional contributors...

 ***************************************************************************/

 *****************************************************************************
 *                                                                           *
 *  This file is part of the OpSim - OPEN SOURCE PROCESS SIMULATOR           *
 *                                                                           *
 *  See the file COPYING.GPL, included in this distribution,                 *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit Thermo;

interface

uses
  SysUtils, Classes, Math, Entities;

type

  TAggregationState = (asUndefined, asSolid, asLiquid, asVapor);

  { Forward declarations }
  TMaterial = class;
  TPhases = class;

  TCompound = class (TCollectionItem)
  protected
    function GetDisplayName: string; override;
    procedure SetIndex(Value: Integer); override;
  public
    CompID: Integer;
    CompName: string;
    CPA: TValueRec;
    CPB: TValueRec;
    CPC: TValueRec;
    CPD: TValueRec;
    DELGF: TValueRec;
    DELHG: TValueRec;
    DIPM: TValueRec;
    Formula: string;
    LDEN: TValueRec;
    MW: TValueRec;
    NEQ: TValueRec;
    PC: TValueRec;
    TB: TValueRec;
    TC: TValueRec;
    TCPHIL: TValueRec;
    TDEN: TValueRec;
    TFP: TValueRec;
    TMAX: TValueRec;
    TMIN: TValueRec;
    VC: TValueRec;
    VPA: TValueRec;
    VPB: TValueRec;
    VPC: TValueRec;
    VPD: TValueRec;
    VSTAR: TValueRec;
    W: TValueRec;
    WSRK: TValueRec;
    ZC: TValueRec;
    Zra: TValueRec;
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  end;
  
  TCompounds = class (TCollection)
  private
    FImmiscibleComponent: Integer;
    FOnNotify: TCollectionNotifyEvent;
    function GetItem(Index: Integer): TCompound;
    procedure SetItem(Index: Integer; Value: TCompound);
  public
    constructor Create;
    function Add: TCompound;
    procedure Assign(Source: TPersistent); override;
    procedure DeleteCompound(ID: Variant);
    function FindCompound(ID: Variant): TCompound;
    procedure Notify(Item: TCollectionItem;  Action: TCollectionNotification); 
            override;
    property ImmiscibleComponent: Integer read FImmiscibleComponent write 
            FImmiscibleComponent;
    property Items[Index: Integer]: TCompound read GetItem write SetItem; 
            default;
  published
    property OnNotify: TCollectionNotifyEvent read FOnNotify write FOnNotify;
  end;
  
  {:
  Holds compound information that is specific for a phase.
  }
  TComposition = class (TCollectionItem)
  public
    Compound: TCompound;
    FugacityCoefficient: TValueRec;
    MassFlow: TValueRec;
    MassFraction: TValueRec;
    MoleFlow: TValueRec;
    MoleFraction: TValueRec;
    StdLiqVolFlow: TValueRec;
    StdLiqVolFraction: TValueRec;
    procedure Assign(Source: TPersistent); override;
  end;
  
  TCompositions = class (TCollection)
  private
    function GetItem(Index: Integer): TComposition;
    procedure SetItem(Index: Integer; Value: TComposition);
  public
    constructor Create;
    function Add: TComposition;
    procedure Assign(Source: TPersistent); override;
    property Items[Index: Integer]: TComposition read GetItem write SetItem; 
            default;
  end;
  
  {:
  - A phase is a stable or metastable collection of compounds with a defined
  amount of substance and a homogeneous composition. It has an associated state
  of aggregation, e.g. liquid. A given phase can be distinguished from others
  through the presence of physical interfaces that separate states of matter
  with different characteristics, such as density (according to CAPE-OPEN).
  - In a material, each phase is given a unique identifier. In order to
  distinguish multiple instances of similar phases, such as liquids, the phase
  can be associated with a number of attributes such as a �key compound�.
  }
  TPhase = class (TCollectionItem)
  private
    FAggregationState: TAggregationState;
    FCompositions: TCompositions;
    FCompressibilityFactor: TValueRec;
    FEnthalpy: TValueRec;
    FEnthalpyDeparture: TValueRec;
    FEntropy: TValueRec;
    FEntropyDeparture: TValueRec;
    FMaterial: TMaterial;
    FMoleVolume: TValueRec;
    FOverallFraction: TValueRec;
    FVolumeFlow: TValueRec;
    function GetCompounds: TCompounds;
    function GetMassFlow: TValueRec;
    function GetMoleFlow: TValueRec;
    function GetPressure: TValueRec;
    function GetStdLiqVolFlow: TValueRec;
    function GetTemperature: TValueRec;
    procedure SetCompounds(Value: TCompounds);
    procedure SetPressure(Value: TValueRec);
    procedure SetTemperature(Value: TValueRec);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property AggregationState: TAggregationState read FAggregationState write 
            FAggregationState;
    property Compositions: TCompositions read FCompositions write FCompositions;
    property Compounds: TCompounds read GetCompounds write SetCompounds;
    property CompressibilityFactor: TValueRec read FCompressibilityFactor write 
            FCompressibilityFactor;
    property Enthalpy: TValueRec read FEnthalpy write FEnthalpy;
    property EnthalpyDeparture: TValueRec read FEnthalpyDeparture write 
            FEnthalpyDeparture;
    property Entropy: TValueRec read FEntropy write FEntropy;
    property EntropyDeparture: TValueRec read FEntropyDeparture write 
            FEntropyDeparture;
    property MassFlow: TValueRec read GetMassFlow;
    property Material: TMaterial read FMaterial write FMaterial;
    property MoleFlow: TValueRec read GetMoleFlow;
    {:
    This is the specific molar volume of the phase.
    }
    property MoleVolume: TValueRec read FMoleVolume write FMoleVolume;
    property OverallFraction: TValueRec read FOverallFraction write 
            FOverallFraction;
    property Pressure: TValueRec read GetPressure write SetPressure;
    property StdLiqVolFlow: TValueRec read GetStdLiqVolFlow;
    property Temperature: TValueRec read GetTemperature write SetTemperature;
    property VolumeFlow: TValueRec read FVolumeFlow write FVolumeFlow;

    function GetPhaseStateStr:String;
  end;
  
  TPhases = class (TCollection)
  private
    FOnNotify: TCollectionNotifyEvent;
    FOwner: TMaterial;
    function GetItem(Index: Integer): TPhase;
    procedure SetItem(Index: Integer; Value: TPhase);
  public
    constructor Create(AMaterial: TMaterial);
    function Add: TPhase;
    procedure Assign(Source: TPersistent); override;
    procedure Notify(Item: TCollectionItem;  Action: TCollectionNotification); 
            override;
    property Items[Index: Integer]: TPhase read GetItem write SetItem; default;
    property Owner: TMaterial read FOwner write FOwner;
  published
    property OnNotify: TCollectionNotifyEvent read FOnNotify write FOnNotify;
  end;
  
  {:
  - A material is a mixture of one or more compounds occurring in one or more
  phases. A material is characterised by the values of physical properties,
  which can describe the overall material or the compounds within particular
  phases. A material often corresponds to a stream in a conventional process
  simulation package  (according to CAPE-OPEN).
  - It is assumed that all phases in a TMaterial have the same temperature and
  pressure.
  - It is expected to be most common that a TMaterial has one or two phases.
  }
  TMaterial = class (TPersistent)
    procedure CompoundsNotify(Item: TCollectionItem; Action: 
            TCollectionNotification);
  private
    FCompositions: TCompositions;
    FCompounds: TCompounds;
    FMassFlow: TValueRec;
    FMoleFlow: TValueRec;
    FPhases: TPhases;
    FPressure: TValueRec;
    FStdLiqVolFlow: TValueRec;
    FTemperature: TValueRec;
    FVolumeFlow: TValueRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    {:
    This method is responsible for delegating flash calculations to the
    associated Property Package or Equilibrium Server. It must set the amounts,
    compositions, temperature and pressure for all phases present at
    equilibrium, as well as the temperature and pressure for the overall
    mixture, if not set as part of the calculation specifications.
    }
    procedure CalcEquilibrium;
    {:
    Verify if extensive properties of the material matches the summation over 
    all phases.
    }
    function CheckBalance: Boolean;
    {:
    - Compositions and additional information for each component in the 
    material.
    - This array holds overall (not for phase) concentrations, flow rates and 
    possibly other properties.
    }
    property Compositions: TCompositions read FCompositions write FCompositions;
    {:
    This is the list of compounds found in the material object.
    }
    property Compounds: TCompounds read FCompounds write FCompounds;
    property MassFlow: TValueRec read FMassFlow write FMassFlow;
    property MoleFlow: TValueRec read FMoleFlow write FMoleFlow;
    {:
    The list of phases present in the material object. Most commonly, there
    will be only one phase.
    }
    property Phases: TPhases read FPhases write FPhases;
    property Pressure: TValueRec read FPressure write FPressure;
    property StdLiqVolFlow: TValueRec read FStdLiqVolFlow write FStdLiqVolFlow;
    property Temperature: TValueRec read FTemperature write FTemperature;
    property VolumeFlow: TValueRec read FVolumeFlow write FVolumeFlow;
  end;



function HVMXID(APhase: TPhase): TValueRec;
procedure IdealKValue(T,P:Real;ACompounds:TCompounds;var K,DKT: array of real);

implementation

procedure IdealKValue(T,P:Real;ACompounds:TCompounds;var K,DKT: array of real);
var
  I : WORD;
  TR,WP1:Real;
Begin
  for I:=0 to ACompounds.Count-1 do
  begin
    with ACompounds.Items[I] do
    begin
      //if (I=0) then W.Value:=0.098;
      //if (I=1) then W.Value:=0.125;
      WP1 := 5.373*(W.Value+1.0);
      TR := TC.Value/T;

      K[I] := EXP(WP1*(1-TR)+LN(PC.Value/P));
      DKT[I] := WP1*(TR/T)*K[I];
    end;
  End;
End;

// Ideal Gas Pure Enthalpy
function HVIG(ACompound: TCompound;T: TValueRec): TValueRec;
const
  TREF = 298.15; // Reference Temperature
var
  HREF: Double; // Ideal Has Enthalpy at the reference Temperature
begin
  //Initializaing result.
  Result.Value := 0;
  with ACompound do begin
    //The reference enthalpy.
    HREF := CPA.Value * TREF + CPB.Value * (TREF ** 2) / 2 +
      CPC.Value * (TREF ** 3) / 3 + CPD.Value * (TREF ** 4) / 4;
    //The actual enthalpy.
    Result.Value := CPA.Value * T.Value + CPB.Value * (T.Value ** 2) / 2 +
      CPC.Value * (T.Value ** 3) / 3 + CPD.Value * (T.Value ** 4) / 4 - HREF;
  end;//with
end;

// Ideal Gas Mixture Enthalpy
function HVMXID(APhase: TPhase): TValueRec;
var
  I: Integer;
  Temp: TValueRec;
begin
  //Initializes the functon return.
  Result.Value := 0;
  with APhase do begin
    //Gets phase's temperature.
    Temp.Value := Temperature.Value;
    //Sum ideal gas enthalpy for all compounds in the phase.
    for I := 0 to Compounds.Count - 1 do
      Result.Value := Result.Value + Compositions[I].MoleFraction.Value * HVIG(Compounds[I], Temp).Value;
  end;//with
end;

// Ideal Gas Pure Entropy
function SVIG(ACompound: TCompound;T: TValueRec;P: TValueRec): TValueRec;
const
  TREF = 298.15; // Reference Temperature
  PREF = 1; // Reference Pressure - 1 Bar
var
  SREF: Double; // Ideal Has Entropy at the reference Temperature and Pressure
begin
  //Initializing return.
  Result.Value := 0;
  with ACompound do begin
    //The reference entropy
    SREF := CPA.Value * Ln(TREF) + CPB.Value * TREF ** 2 +
            0.5 * CPC.Value * TREF ** 3 + (1.0 / 3.0) * CPD.Value * TREF ** 3
            - Ln(PREF);
    //The entropy
    Result.Value := CPA.Value * Ln(T.Value) + CPB.Value * (T.Value) +
                    0.5 * CPC.Value * (T.Value ** 2) +
                    (1.0 / 3.0) * CPD.Value * (T.Value ** 3)
                    - 8.314 * Ln(P.Value) - SREF;
  end;//with
end;

// Ideal Gas Mixture Entropy
function SVMXID(APhase: TPhase): TValueRec;
var
  I: Integer;
  Temp: TValueRec;
  Pres: TValueRec;
begin
  //Initializes the function return.
  Result.Value := 0;
  with APhase do begin
   //Gets phase's temperature.
    Temp.Value := Temperature.Value;
    Pres.Value := Pressure.Value;
    //Sum ideal gas entropy for all compounds in the phase.
    for I := 0 to Compounds.Count - 1 do
      if Compositions[I].MoleFraction.Value > 0 Then
        Result.Value := Result.Value + Compositions[I].MoleFraction.Value *
                        SVIG(Compounds[I], Temp, Pres).Value - 8.314 *
                        Compositions[I].MoleFraction.Value * Ln(Compositions[I].MoleFraction.Value);
  end;//with
end;


{
********************************** TCompound ***********************************
}
constructor TCompound.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
end;

destructor TCompound.Destroy;
begin
  inherited Destroy;
end;

procedure TCompound.Assign(Source: TPersistent);
begin
  if Source is TCompound then begin
    with TCompound(Source) do begin
      Self.CompID := CompID;
      Self.CompName := CompName;
      Self.CPB := CPB;
      Self.CPA := CPA;
      Self.CPC := CPC;
      Self.CPD := CPD;
      Self.DELGF := DELGF;
      Self.DELHG := DELHG;
      Self.DIPM := DIPM;
      Self.Formula := Formula;
      Self.LDEN := LDEN;
      Self.MW := MW;
      Self.NEQ := NEQ;
      Self.PC := PC;
      Self.TB := TB;
      Self.TC := TC;
      Self.TCPHIL := TCPHIL;
      Self.TDEN := TDEN;
      Self.TFP := TFP;
      Self.TMAX := TMAX;
      Self.TMIN := TMIN;
      Self.VC := VC;
      Self.VPA := VPA;
      Self.VPB := VPB;
      Self.VPC := VPC;
      Self.VPD := VPD;
      Self.VSTAR := VSTAR;
      Self.W := W;
      Self.WSRK := WSRK;
      Self.ZC := ZC;
      Self.Zra := Zra;
    end;//with
  end
  else
    inherited Assign(Source);
end;

function TCompound.GetDisplayName: string;
begin
  if Result = '' then Result := inherited GetDisplayName;
end;

procedure TCompound.SetIndex(Value: Integer);
begin
  inherited SetIndex(Value);
end;


{
********************************** TCompounds **********************************
}
constructor TCompounds.Create;
begin
  inherited Create(TCompound);
end;

function TCompounds.Add: TCompound;
begin
  Result := TCompound(inherited Add);
end;

procedure TCompounds.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TCompounds then begin
    //Clear current list.
    Clear;
    //Copy all compounds from Source.
    with TCompounds(Source) do
      for I := 0 to Count - 1 do
        Self.Add.Assign(Items[I]);

    ImmiscibleComponent:=TCompounds(Source).ImmiscibleComponent;
    OnNotify:=TCompounds(Source).OnNotify;

  end
  else
    inherited Assign(Source);
end;

procedure TCompounds.DeleteCompound(ID: Variant);
var
  C: TCompound;
begin
  C := FindCompound(ID);
  if C <> nil then
    Delete(C.Index);
end;

function TCompounds.FindCompound(ID: Variant): TCompound;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].CompID = ID then begin
      Result := Items[I];
      Break;
    end;//if
end;

function TCompounds.GetItem(Index: Integer): TCompound;
begin
  Result := TCompound(inherited GetItem(Index));
end;

procedure TCompounds.Notify(Item: TCollectionItem;  Action: 
        TCollectionNotification);
begin
  inherited Notify(Item, Action);
  if Assigned(FOnNotify) then
    FOnNotify(Item, Action);
end;

procedure TCompounds.SetItem(Index: Integer; Value: TCompound);
begin
  inherited SetItem(Index, Value);
end;

{
********************************* TComposition *********************************
}
procedure TComposition.Assign(Source: TPersistent);
begin
  if Source is TComposition then begin
    with TComposition(Source) do begin
      Self.Compound := Compound;
      Self.FugacityCoefficient := FugacityCoefficient;
      Self.MassFlow := MassFlow;
      Self.MassFraction := MassFraction;
      Self.MoleFlow := MoleFlow;
      Self.MoleFraction := MoleFraction;
      Self.StdLiqVolFlow := StdLiqVolFlow;
      Self.StdLiqVolFraction := StdLiqVolFraction;
    end;//with
  end
  else
    inherited Assign(Source);
end;


{
******************************** TCompositions *********************************
}
constructor TCompositions.Create;
begin
  inherited Create(TComposition);
end;

function TCompositions.Add: TComposition;
begin
  Result := TComposition(inherited Add);
end;

procedure TCompositions.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TCompositions then begin
    //Clear current list.
    Clear;
    //Copy all compositions items from Source.
    with TCompositions(Source) do
      for I := 0 to Count - 1 do
        Self.Add.Assign(Items[I]);
  end
  else
    inherited Assign(Source);
end;

function TCompositions.GetItem(Index: Integer): TComposition;
begin
  Result := TComposition(inherited GetItem(Index));
end;

procedure TCompositions.SetItem(Index: Integer; Value: TComposition);
begin
  inherited SetItem(Index, Value);
end;


{
************************************ TPhase ************************************
}
constructor TPhase.Create(Collection: TCollection);
var
  I: Integer;
begin
  inherited Create(Collection);
  FCompositions := TCompositions.Create;
  //Defines the material to which the phase pertains.
  if Collection <> nil then
    FMaterial := (Collection as TPhases).Owner;
  //The size of Compositions array must match the size of the Compounds array in
  //the owner Material instance.
  with Compounds do
    for I := 0 to Count - 1 do
      FCompositions.Add;
end;

destructor TPhase.Destroy;
begin
  FCompositions.Free;
  inherited Destroy;
end;

procedure TPhase.Assign(Source: TPersistent);
begin
  if Source is TPhase then begin
    with TPhase(Source) do begin
      Self.AggregationState := AggregationState;
      Self.CompressibilityFactor := CompressibilityFactor;
      Self.Enthalpy := Enthalpy;
      Self.EnthalpyDeparture := EnthalpyDeparture;
      Self.Entropy := Entropy;
      Self.EntropyDeparture := EntropyDeparture;
      Self.MoleVolume := MoleVolume;
      Self.OverallFraction := OverallFraction;
      Self.VolumeFlow := VolumeFlow;
      Self.Material := Material;
      //Copy compositions.
      Self.Compositions.Assign(Compositions);
    end;//with
  end
  else
    inherited Assign(Source);
end;

function TPhase.GetCompounds: TCompounds;
begin
  Result := Material.Compounds;
end;

function TPhase.GetMassFlow: TValueRec;
var
  I: Integer;
begin
  //The mass flow for the phase is the summation over all compounds.
  Result.Value := 0;
  with FCompositions do
    for I := 0 to Count - 1 do
      Result.Value := Result.Value + Items[I].MassFlow.Value;
end;

function TPhase.GetMoleFlow: TValueRec;
var
  I: Integer;
begin
  //The mole flow rate for the phase is the summation over all compounds.
  Result.Value := 0;
  with FCompositions do
    for I := 0 to Count - 1 do
      Result.Value := Result.Value + Items[I].MoleFlow.Value;
end;

function TPhase.GetPressure: TValueRec;
begin
  Result := Material.Pressure;
end;

function TPhase.GetStdLiqVolFlow: TValueRec;
var
  I: Integer;
begin
  //The StdLiqVolFlow for the phase is the summation over all compounds.
  Result.Value := 0;
  with FCompositions do
    for I := 0 to Count - 1 do
      Result.Value := Result.Value + Items[I].StdLiqVolFlow.Value;
end;

function TPhase.GetTemperature: TValueRec;
begin
  Result := Material.Temperature;
end;

procedure TPhase.SetCompounds(Value: TCompounds);
begin
  Material.Compounds := Value;
end;

procedure TPhase.SetPressure(Value: TValueRec);
begin
  Material.Pressure := Value;
end;

procedure TPhase.SetTemperature(Value: TValueRec);
begin
  Material.Temperature := Value;
end;

function TPhase.GetPhaseStateStr:String;
var
  S : String;
begin
  S:='Undefined';
  case AggregationState of
    asUndefined: S:='Undefined';
    asSolid: S:='Solid';
    asLiquid: S:='Liquid';
    asVapor: S:='Vapor';
  end;
  Result := S;
end;

{
*********************************** TPhases ************************************
}
constructor TPhases.Create(AMaterial: TMaterial);
begin
  inherited Create(TPhase);
  FOwner := AMaterial;
end;

function TPhases.Add: TPhase;
begin
  Result := TPhase(inherited Add);
end;

procedure TPhases.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TPhases then begin
    //Clear current list.
    Clear;
    //Copy all phase items from Source.
    with TPhases(Source) do
      for I := 0 to Count - 1 do
        Self.Add.Assign(Items[I]);
  end
  else
    inherited Assign(Source);
end;

function TPhases.GetItem(Index: Integer): TPhase;
begin
  Result := TPhase(inherited GetItem(Index));
end;

procedure TPhases.Notify(Item: TCollectionItem;  Action: 
        TCollectionNotification);
begin
  inherited Notify(Item, Action);
  if Assigned(FOnNotify) then
    FOnNotify(Item, Action);
end;

procedure TPhases.SetItem(Index: Integer; Value: TPhase);
begin
  inherited SetItem(Index, Value);
end;


{
********************************** TMaterial ***********************************
}
constructor TMaterial.Create;
begin
  inherited Create;
  FCompounds := TCompounds.Create;
  FCompositions := TCompositions.Create;
  FPhases := TPhases.Create(Self);
  
  FCompounds.OnNotify := CompoundsNotify;
end;

destructor TMaterial.Destroy;
begin
  FCompounds.Free;
  FCompositions.Free;
  FPhases.Free;
  inherited Destroy;
end;

procedure TMaterial.Assign(Source: TPersistent);
begin
  if Source is TMaterial then begin
    with TMaterial(Source) do begin
      Self.Temperature := Temperature;
      Self.Pressure := Pressure;
      Self.MassFlow := MassFlow;
      Self.MoleFlow := MoleFlow;
      Self.StdLiqVolFlow := StdLiqVolFlow;
      Self.VolumeFlow := VolumeFlow;
      //Copy the lists.
      Self.Compounds.Assign(Compounds);
      Self.Compositions.Assign(Compositions);
      Self.Phases.Assign(Phases);
    end;//with
  end
  else
    inherited Assign(Source);
end;

procedure TMaterial.CalcEquilibrium;
begin
end;

function TMaterial.CheckBalance: Boolean;
var
  I: Integer;
  TotalMassFlow, TotalMoleFlow, TotalStdLiqVolFlow: Real;
begin
  TotalMassFlow := 0;
  TotalMoleFlow := 0;
  TotalStdLiqVolFlow := 0;
  
  //Get totals for all phases.
  with FPhases do
    for I := 0 to Count - 1 do begin
      //The mass flow rate for the material is the summation over all phases.
      TotalMassFlow := TotalMassFlow + Items[I].MassFlow.Value;
      //The mole flow rate for the material is the summation over all phases.
      TotalMoleFlow := TotalMoleFlow + Items[I].MoleFlow.Value;
      //The StdLiqVolFlow for the material is the summation over all phases.
      TotalStdLiqVolFlow := TotalStdLiqVolFlow + Items[I].StdLiqVolFlow.Value;
    end;//for
  
  //Returns True if everything matches.
  Result := SameValue(FMassFlow.Value, TotalMassFlow) and
            SameValue(FMoleFlow.Value, TotalMoleFlow) and
            SameValue(FStdLiqVolFlow.Value, TotalStdLiqVolFlow);
end;

procedure TMaterial.CompoundsNotify(Item: TCollectionItem; Action: 
        TCollectionNotification);
var
  I: Integer;
begin
  case Action of
  
    cnAdded: begin
      //Open room for auxiliary information on the phases.
      with FPhases do
        for I := 0 to Count - 1 do
          Phases[I].Compositions.Add;
      //The same for the material compositions.
      FCompositions.Add;
    end;//cnAdded
  
    cnDeleting: begin
      //Free auxiliary information on the phases.
      with FPhases do
        for I := 0 to Count - 1 do
          Phases[I].Compositions.Delete(Item.Index);
      //The same for the material compositions.
      FCompositions.Delete(Item.Index);
    end;//cnDeleting
  
  end;//case
end;

end.
