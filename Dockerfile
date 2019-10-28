FROM microsoft/dotnet:2.0.3-runtime AS base
WORKDIR /app

FROM microsoft/dotnet:2.0.3-sdk AS build
WORKDIR /src
COPY Example.csproj .
RUN dotnet restore "Example.csproj"
COPY . .
WORKDIR /src
RUN dotnet build "Example.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Example.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Example.dll"]