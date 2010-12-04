unit NProvider.Collection;

interface

uses Classes, NProviderBase;

type

  TProviderCollection = class(TObject)
  private
    FProviders: TList;
    function GetProviderCount: integer;
  protected
    function GetProvider(const ProviderName: string): TProviderBase; virtual;
    procedure CleanProviders;

  public
    constructor Create;
    destructor Destroy; override;
    function ProviderNamesToVariant: OleVariant;
    procedure RegisterProvider(Value: TProviderBase); virtual;
    procedure UnRegisterProvider(Value: TProviderBase); virtual;
    property Providers[const ProviderName: string]: TProviderBase read GetProvider;
    property ProviderCount: integer read GetProviderCount;
  end;

implementation

{ TProviderCollection }

procedure TProviderCollection.CleanProviders;
begin

end;

constructor TProviderCollection.Create;
begin

end;

destructor TProviderCollection.Destroy;
begin

  inherited;
end;

function TProviderCollection.GetProvider(const ProviderName: string): TProviderBase;
begin

end;

function TProviderCollection.GetProviderCount: integer;
begin

end;

function TProviderCollection.ProviderNamesToVariant: OleVariant;
begin

end;

procedure TProviderCollection.RegisterProvider(Value: TProviderBase);
begin
  if Assigned(Value) then
    raise ArgumentNullException('The provider parameter cannot be null');
  base.Add(provider);
end;

procedure TProviderCollection.UnRegisterProvider(Value: TProviderBase);
begin

end;

end.
