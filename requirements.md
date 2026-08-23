have some basic infr around it like kafka for all the events that need to be sent out?
have some monitoring, thinking clickhosue x grafana
should definitely be asynchronous
should defintiely be at least once delivery
horizontal scale


so each of these webhook servesr are actually more like workers.
each worker has to be comleletely stateless
they have to be able to pull from some queue which ahs at minimum
the data to send
who to send it to
would proably amke sense to have differnet topics pere retry queue


so this will kinda be like an infra problem
i will have a queue 


shoudl defintiely have some general purpose even object with data that can be any json ?
yes. that makes the most sense. then i can just have event.type. basically im just going to mirror what stripe has

cuz as a client, youll hav eto accept a typed object and you just wont know what webhook evnet is going to come flyign through 

- the client can define what endpoint to send events to
- retry strategy
- scale as much as possible
