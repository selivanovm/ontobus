package ru.magnetosoft.esb.mq.context;

import ru.magnetosoft.jtoolbox.resources.Resource;

public interface ContextFactory
{
	Context newContext(Resource rc);
}
