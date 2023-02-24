#pragma warning disable 213
#pragma warning disable 239

#include <a_samp>
#include <Pawn.CMD>
#include <sscanf2>

#define FILTERSCRIPT
#define VEHICLE_CONSULT_DIALOG 5;

#if defined FILTERSCRIPT

enum E_TRAFFIC_TICKET {
  E_TRAFFIC_TICKET_ID,
  E_VEHICLE_ID,
  E_VEHICLE_LICENSE_PLATE[9],
  E_TRAFFIC_TICKET_VALUE,
  E_PLACE_OF_INFRACTION[15],
}

enum E_VEHICLE {
  E_VEHICLE_MODEL_ID,
  E_VEHICE_OWNER_ID,
  E_VEHICE_OWNER_NAME[MAX_PLAYER_NAME],
  E_VEHICLE_ID,
  E_VEHICLE_LICENSE_PLATE[9],
}

new Vehicle[MAX_VEHICLES][E_VEHICLE];
new TrafficTicket[MAX_VEHICLES][E_TRAFFIC_TICKET];

new vehiclesCount = 0;
new trafficTicketsCount = 0;

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 0;
}

stock GetPlayerUsername(playerid)
{
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	return playerName;
}

stock SetVehicleLicensePlate(vehicleId, vehicleLicensePlate[]) {
  format(Vehicle[vehicleId][E_VEHICLE_LICENSE_PLATE], 9, "%s", vehicleLicensePlate);
  SetVehicleNumberPlate(vehicleId, Vehicle[vehicleId][E_VEHICLE_LICENSE_PLATE]);
  SetVehicleToRespawn(vehicleId);

  return 1;
}
 
stock GetVehicleLicensePlate(vehicleId) {
  new vehicleLicensePlate[9];

  for(new i = 0; i < 9; i++) {
    strcat(vehicleLicensePlate, Vehicle[vehicleId][E_VEHICLE_LICENSE_PLATE][i]);
  }

  return vehicleLicensePlate;
}

CMD:criarveiculo(playerid, params[])
{
  new vehicleId, color[2], vehicleLicensePlate[9];

  if(sscanf(params, "ddds[9]", vehicleId, color[0], color[1], vehicleLicensePlate))
  {
    new message[150];
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando invalido, por favor utilize: /criarveiculo [ID do veiculo] [cor primaria] [cor secundaria] [placa].");
    return SendClientMessage(playerid, -1, message);
  }

  new Float:vehicleXPosition, Float:vehicleYPosition, Float:vehicleZPosition, Float:vehicleAnglePosition;

  GetPlayerPos(playerid, vehicleXPosition, vehicleYPosition, vehicleZPosition);
  GetPlayerFacingAngle(playerid, vehicleAnglePosition);
  Vehicle[vehiclesCount][E_VEHICLE_MODEL_ID] = vehicleId;
  Vehicle[vehiclesCount][E_VEHICE_OWNER_ID] = playerid;
  Vehicle[vehiclesCount][E_VEHICE_OWNER_NAME] = GetPlayerUsername(playerid);
  Vehicle[vehiclesCount][E_VEHICLE_ID] = AddStaticVehicle(vehicleId, vehicleXPosition, vehicleYPosition - 2, vehicleZPosition, vehicleAnglePosition, color[0], color[1]);
  SetVehicleLicensePlate(Vehicle[vehiclesCount][E_VEHICLE_ID], vehicleLicensePlate);
  vehiclesCount++;

  new message[150];
  
  format(message, sizeof(message), "{FFD700}Modelo do Veiculo: {FFFFFF}%d {FFD700}- ID gerado do veiculo: {FFFFFF}%d {FFD700}- Placa: {FFFFFF}%s{FFD700}.", vehicleId, vehiclesCount, vehicleLicensePlate);
  SendClientMessage(playerid, -1, message);

  return 1;
}

CMD:consultarveiculo(playerid, params[])
{
  new playerId, vehicleLicensePlate[9];
  new message[400];

  if(sscanf(params, "ds[9]", playerId, vehicleLicensePlate))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando invalido, por favor utilize: /consultarveiculo [ID do jogador] [placa do veiculo].");
    return SendClientMessage(playerid, -1, message);
  }

  if(vehiclesCount == 0)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Nao foi possivel executar o comando pois nao ha veiculos criados.");
    return SendClientMessage(playerid, -1, message);
  }

  for(new i = 0; i < vehiclesCount; i++)
  {
    if(Vehicle[i][E_VEHICE_OWNER_ID] == playerId && strcmp(GetVehicleLicensePlate(Vehicle[i][E_VEHICLE_ID]), vehicleLicensePlate) == 0)
    { 
      format(message, sizeof(message), "{FF0000}+{FFD700}-----------------------------------{FF0000}+\n{00FF00}Modelo: {FFFFFF}%d{00FF00}.\n{00FF00}ID do dono: {FFFFFF}%d{00FF00}.\n{00FF00}Nome do dono: {FFFFFF}%s{00FF00}.\n{00FF00}ID do veiculo: {FFFFFF}%d{00FF00}.\n{00FF00}Placa do veiculo: {FFFFFF}%s{00FF00}.\n{FF0000}+{FFD700}-----------------------------------{FF0000}+", Vehicle[i][E_VEHICLE_MODEL_ID], Vehicle[i][E_VEHICE_OWNER_ID], Vehicle[i][E_VEHICE_OWNER_NAME], Vehicle[i][E_VEHICLE_ID], GetVehicleLicensePlate(Vehicle[i][E_VEHICLE_ID]));
      ShowPlayerDialog(playerid, 5, DIALOG_STYLE_MSGBOX, "DETRAN - Consulta de Veiculo", message, "Fechar", "");
    } else
    {
      format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Nao foi possivel encontrar o veiculo com o ID do jogador e placa do veiculo informados.");
      SendClientMessage(playerid, -1, message);
    }
  }

  return 1;
}

CMD:darmulta(playerid, params[])
{
  new playerId, vehicleLicensePlate[9], placeOfInfraction[15], trafficTicketValue;
  new message[400];

  if(sscanf(params, "ds[9]s[12]d", playerId, vehicleLicensePlate, placeOfInfraction, trafficTicketValue))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando invalido, por favor utilize: /darmulta [ID do jogador] [placa do veiculo] [local da infração] [valor da multa].");
    return SendClientMessage(playerid, -1, message);
  }

  if(vehiclesCount == 0)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Nao foi possivel executar o comando pois nao ha veiculos criados.");
    return SendClientMessage(playerid, -1, message);
  }

  for(new i = 0; i < vehiclesCount; i++)
  {
    if(Vehicle[i][E_VEHICE_OWNER_ID] == playerId && strcmp(GetVehicleLicensePlate(Vehicle[i][E_VEHICLE_ID]), vehicleLicensePlate) == 0)
    {
      TrafficTicket[trafficTicketsCount][E_TRAFFIC_TICKET_ID] += 1;
      TrafficTicket[trafficTicketsCount][E_VEHICLE_ID] = Vehicle[i][E_VEHICLE_ID];
      TrafficTicket[trafficTicketsCount][E_VEHICLE_LICENSE_PLATE] = GetVehicleLicensePlate(Vehicle[i][E_VEHICLE_ID]);
      TrafficTicket[trafficTicketsCount][E_TRAFFIC_TICKET_VALUE] = trafficTicketValue;
      TrafficTicket[trafficTicketsCount][E_PLACE_OF_INFRACTION] = placeOfInfraction;
      trafficTicketsCount++;
      format(message, sizeof(message), "{FF0000}[DETRAN] {FFD700}Voce recebeu uma multa no valor de R$%d,00. Dirija-se ao DETRAN mais proximo para efetuar o pagamento.", trafficTicketValue);
      SendClientMessage(playerId, -1, message);
    } else
    {
      format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Veiculo de placa %s nao encontrado. %s", vehicleLicensePlate, GetVehicleLicensePlate(Vehicle[i][E_VEHICLE_ID]));
      return SendClientMessage(playerid, -1, message);
    }
  }

  return 1;
}

CMD:consultarmultas(playerid, params[])
{
  new vehicleLicensePlate[9];
  new message[300];

  if(sscanf(params, "s[9]", vehicleLicensePlate))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando invalido, por favor utilize: /consultarmultas [placa do veiculo].");
    return SendClientMessage(playerid, -1, message);
  }

  if(vehiclesCount == 0)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Nao foi possivel executar o comando pois nao ha veiculos criados.");
    return SendClientMessage(playerid, -1, message);
  }

  for(new i = 0; i < vehiclesCount; i++)
  {
    if(strcmp(GetVehicleLicensePlate(TrafficTicket[i][E_VEHICLE_ID]), vehicleLicensePlate) == 0 && trafficTicketsCount > 0)
    {
      if(Vehicle[i][E_VEHICLE_ID] == TrafficTicket[i][E_VEHICLE_ID])
      {
        for(new j = 0; j < trafficTicketsCount; j++)
        {
          format(message, sizeof(message), "ID: %d - Multa: R$%d,00.", j + 1, TrafficTicket[j][E_TRAFFIC_TICKET_VALUE]);
          SendClientMessage(playerid, -1, message);
        }
      }
    } else
    {
      format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Nao foram encontradas multas no veiculo com a placa informada.");
      return SendClientMessage(playerid, -1, message);
    }
  }

  return 1;
}

#endif