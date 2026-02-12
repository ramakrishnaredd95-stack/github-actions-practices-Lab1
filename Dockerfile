# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy solution file
COPY FlipkartMobile.sln .

# Copy project files
COPY FlipkartMobilePage/FlipkartMobilePage.csproj FlipkartMobilePage/
COPY FlipkartMobilePage.Tests/FlipkartMobilePage.Tests.csproj FlipkartMobilePage.Tests/

# Restore dependencies
RUN dotnet restore FlipkartMobile.sln

# Copy all source files
COPY . .

# Build the application
WORKDIR /src/FlipkartMobilePage
RUN dotnet build FlipkartMobilePage.csproj -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish FlipkartMobilePage.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Copy published files from publish stage
COPY --from=publish /app/publish .

# Set entry point
ENTRYPOINT ["dotnet", "FlipkartMobilePage.dll"]
