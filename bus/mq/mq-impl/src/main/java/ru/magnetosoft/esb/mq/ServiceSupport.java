package ru.magnetosoft.esb.mq;

import ru.magnetosoft.esb.mq.context.Context;

public interface ServiceSupport extends Service
{
	void doInit(Context context);
}
