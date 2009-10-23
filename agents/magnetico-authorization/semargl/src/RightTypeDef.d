module RightTypeDef;

public static char* rt_symbols = "crwud";

enum RightType
{
	CREATE = 0,
	READ = 1,
	WRITE = 2,
	UPDATE = 3,
	DELETE = 4
}