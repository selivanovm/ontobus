message='<subject><get_authorization_rights_records>"uid1".<uid1><argument>{<recId><magnet-ontology#authorSystem>"".<recId><magnet-ontology#authorSubsystem>"".<recId><magnet-ontology#authorSubsystemElement>"".<recId><magnet-ontology#targetSystem>"".<recId><magnet-ontology#targetSubsystem>"".<recId><magnet-ontology#targetSubsystemElement>"".<recId><magnet-ontology#category>"".<recId><magnet-ontology#elementId>"".}.'

java -cp ./:lib/commons-io-1.2.jar:lib/commons-cli-1.1.jar:lib/rabbitmq-client.jar:lib/scala-library.jar Client $message 192.168.150.196 5672 magnetico test test eks 123456 0 "" direct true