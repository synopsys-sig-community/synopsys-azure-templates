FROM ubuntu:18.04

ENV COVERITY_VERSION=2021.12.1
ENV COVERITY_LICENSE ""

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu60 \
    libunwind8 \
    netcat \
    libssl1.0 \
    unzip \
    openjdk-8-jdk \
    python3 \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip && pip3 install setuptools requests==2.26.0 urllib3==1.26.7 jsonapi-requests==0.6.2 tenacity==6.2.0 pygithub suds azure-devops

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.194.0

WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

COPY cov-analysis-linux64-${COVERITY_VERSION}.tar.gz ./
RUN tar xzf cov-analysis-linux64-${COVERITY_VERSION}.tar.gz && rm cov-analysis-linux64-${COVERITY_VERSION}.tar.gz && mv cov-analysis-linux64-${COVERITY_VERSION} cov-analysis-linux64

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
