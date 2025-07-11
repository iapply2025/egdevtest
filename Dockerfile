FROM rockylinux:9-minimal AS build

RUN microdnf install -y epel-release && \
    microdnf update -y && \
    microdnf install -y python3.12 python3.12-pip python3.12-devel gcc git curl make && \
    microdnf clean all

RUN curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - && \
    microdnf install -y nodejs && \
    npm install -g pnpm && \
    microdnf clean all

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /opt/egzakta/devops-test

COPY devops-test /opt/egzakta/devops-test
COPY devops-test/README.md /opt/egzakta/devops-test/backend/

RUN cd backend && \
    poetry install --no-root --no-interaction && \
    poetry build

### FINAL IMAGE

FROM rockylinux:9-minimal

RUN microdnf install -y epel-release && \
    microdnf update -y && \
    microdnf install -y python3.12 python3.12-pip && \
    microdnf clean all

RUN useradd -m egzakta

WORKDIR /opt/egzakta/devops-test

COPY devops-test/app/app.py /opt/egzakta/devops-test/app/app.py
COPY --from=build /opt/egzakta/devops-test/backend/dist/*.whl /opt/egzakta/devops-test/backend/dist/

RUN pip3.12 install /opt/egzakta/devops-test/backend/dist/*.whl

RUN chown -R egzakta:egzakta /opt/egzakta

USER egzakta

EXPOSE 8000

ENV PORT=8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl --fail --silent --head http://localhost:${PORT}/ || exit 1

ENTRYPOINT ["sh", "-c", "chainlit run app/app.py -h --port $PORT --host 0.0.0.0"]
