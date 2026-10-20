const fastify = require('fastify')({
    bodyLimit: 10485760,
    logger: {
        level: "info",
        transport: { target: 'pino-pretty' }
    }
});

fastify.register(require('@fastify/helmet'));

fastify.register(require('@fastify/cors'));

fastify.register(require('@fastify/rate-limit'), {
    global: true,
    max: 300,
    timeWindow: '1 minut'
});

fastify.register(require('@fastify/multipart'), {
    limits: { fileSize: 500 * 1024 * 1024, files: 1 }
});

const start = async () => {
    try {
        await fastify.ready();

        const port = 3000;
        fastify.listen({ port: port, host: "0.0.0.0" });

        console.log("Sunucu basariyla baslatildi");

    } catch (error) {
        console.error("Kritik sunucu baslatma hatasi");
        console.error(error);
        console.error(1);
    }
}

start();