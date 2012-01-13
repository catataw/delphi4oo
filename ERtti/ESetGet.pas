unit ESetGet;

interface

uses
  EIntf;

type

  /// <summary>
  /// This class is responsible for setting a value on a field choosen by its field  name.
  /// </summary>
  TFieldSetterByName = class(EObject, IFieldSetter)
  private
    FfieldName: string;
    Ftarget: TObject;
    // private final Class<?> clazz;
    // final ReflectionProvider provider;
  protected
    procedure withValue(Value: TObject);
  public
    // (final ReflectionProvider provider, final String fieldName, final Object target,final Class<?> clazz)
    constructor create;
  end;

  TFieldSetterByField = class(EObject, IFieldSetter)
  protected
    procedure withValue(Value: TObject);
  public
    constructor create;
  end;

  /// <summary>
  /// This class is responsible for providing field setting features.
  /// </summary>
  TSetterHandler = class(EObject, ISetterHandler)
  protected
    function FieldSetter(fieldName: string): EField; overload;
    function FieldSetter(Field: EField): EField; overload;
  end;

  TGetterHandler = class(EObject, IGetterHandler)
  protected
    function FieldGetter(fieldName: string): EField; overload;
    function FieldGetter(Field: EField): EField; overload;
  end;

implementation

{ TFieldSetterByName }

constructor TFieldSetterByName.create;
begin
  { if ((fieldName == null) || (fieldName.trim().length() == 0)) {
    throw new IllegalArgumentException("fieldName cannot be null or blank");


    if (clazz == null) {
    throw new IllegalArgumentException("clazz cannot be null");


    this.provider = provider;
    this.fieldName = fieldName;
    this.target = target;
    this.clazz = clazz; }
end;

procedure TFieldSetterByName.withValue(Value: TObject);
begin
  { Field field = new Mirror(provider).on(clazz).reflect().field(fieldName);
    if (field == null) {
    throw new MirrorException("could not find field " + fieldName + " on class " + clazz.getName());

    new FieldSetterByField(provider, target, clazz, field).withValue(value); }
end;

{ TFieldSetterByField }

constructor TFieldSetterByField.create;
begin
  { if (clazz == null) {
    throw new IllegalArgumentException("clazz cannot be null");
    if (field == null) {
    throw new IllegalArgumentException("field cannot be null");

    if (!field.getDeclaringClass().isAssignableFrom(clazz)) {
    throw new IllegalArgumentException("field declaring class (" + field.getDeclaringClass().getName()
    + ") doesn't match clazz " + clazz.getName());

    this.provider = provider;
    this.target = target;
    this.clazz = clazz;
    this.field = field; }
end;

procedure TFieldSetterByField.withValue(Value: TObject);
begin
  { if ((target == null) && !Modifier.isStatic(field.getModifiers())) {
    throw new MirrorException("attempt to set instance field " + field.getName() + " on class "
    + clazz.getName());

    if ((value == null) && field.getType().isPrimitive()) {
    throw new IllegalArgumentException("cannot set null value on primitive field");

    if (value != null) {
    MatchType match = new ClassArrayMatcher(value.getClass()).match(field.getType());
    if (MatchType.DONT_MATCH.equals(match)) {
    throw new IllegalArgumentException("Value of type " + value.getClass() + " cannot be set on field "
    + field.getName() + " of type " + field.getType() + " from class " + clazz.getName()
    + ". Incompatible types");
    FieldReflectionProvider fieldReflectionProvider = provider.getFieldReflectionProvider(target, clazz, field);
    fieldReflectionProvider.setAccessible();
    fieldReflectionProvider.setValue(value); }
end;

{ TDefaultSetterHandler }

function TSetterHandler.FieldSetter(fieldName: string): EField;
begin

end;

function TSetterHandler.FieldSetter(Field: EField): EField;
begin

end;

{ TGetterHandler }

function TGetterHandler.FieldGetter(fieldName: string): EField;
begin

end;

function TGetterHandler.FieldGetter(Field: EField): EField;
begin

end;

end.
