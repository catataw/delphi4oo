unit DataBase.Mensagens;

interface

resourcestring

  rErrorConnectionStringCannotEmpty = '%s.connectionString cannot be empty';
  rErrorConnectionOpenDb = 'CDbConnection failed to open the DB connection: %s';
  rErrorConnectionInactive = '%s is inactive and cannot perform any DB operations.';
  rErrorTransactionInactive = '%s is inactive and cannot perform commit or roll back operations.';
  rErrorCommandPrepare = 'CDbCommand failed to prepare the SQL statement: %s';
  rErrorCommandExecute = 'CDbCommand failed to execute the SQL statement: %s';

implementation

end.
