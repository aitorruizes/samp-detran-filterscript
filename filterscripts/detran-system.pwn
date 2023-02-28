#pragma warning disable 213
#pragma warning disable 239

#include <a_samp>
#include <Pawn.CMD>
#include <sscanf2>

#define FILTERSCRIPT

#if defined FILTERSCRIPT

enum E_VEHICLE {
  E_VEHICLE_MODEL_ID,
  E_VEHICE_OWNER_ID,
  E_VEHICE_OWNER_NAME[MAX_PLAYER_NAME],
  E_CREATED_VEHICLE_ID,
  E_VEHICLE_LICENSE_PLATE[9],
  E_IS_VEHICLE_TOWED
}

new Vehicle[MAX_VEHICLES][E_VEHICLE];
new createdVehiclesCount = 0;
new towMessage[MAX_PLAYERS];

forward TowVehicle(targetPlayerId, playerid);
public TowVehicle(targetPlayerId, playerid)
{
  new targetVehicleId;
  new Float:x, Float:y, Float: z, Float:a;
  targetVehicleId = GetPlayerVehicleID(playerid);
  GetVehiclePos(targetVehicleId, x, y, z);
  GetVehicleZAngle(targetVehicleId, a);
  SetVehiclePos(Vehicle[targetPlayerId][E_CREATED_VEHICLE_ID], x, y, z + 1);
  PlayerPlaySound(playerid, 1133, x, y, z);
  Vehicle[targetPlayerId][E_IS_VEHICLE_TOWED] = true;

  PlayerTextDrawHide(playerid, towMessage[playerid]);

  new message[150];
  format(message, sizeof(message), "{FF0000}[DETRAN] {FFD700}Ve�culo de placa %s rebocado com sucesso!", GetVehicleLicensePlate(Vehicle[targetPlayerId][E_CREATED_VEHICLE_ID]));
  SendClientMessage(playerid, -1, message);

  return 1;
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
 
stock GetVehicleLicensePlate(vehicleId)
{
  new vehicleLicensePlate[9];

  for(new i = 0; i < 9; i++) {
    strcat(vehicleLicensePlate, Vehicle[vehicleId][E_VEHICLE_LICENSE_PLATE][i]);
  }

  return vehicleLicensePlate;
}

CMD:criarveiculo(playerid, params[])
{
  new vehicleId;
  new color[2];
  new vehicleLicensePlate[9];
  new message[150];
  
  if(sscanf(params, "ddds[9]", vehicleId, color[0], color[1], vehicleLicensePlate))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando inv�lido, por favor utilize: /criarve�culo [ID do ve�culo] [cor primaria] [cor secundaria] [placa].");
    return SendClientMessage(playerid, -1, message);
  }

  if(createdVehiclesCount == 0)
  {
    new Float:vehicleXPosition, Float:vehicleYPosition, Float:vehicleZPosition, Float:vehicleAnglePosition;

    GetPlayerPos(playerid, vehicleXPosition, vehicleYPosition, vehicleZPosition);
    GetPlayerFacingAngle(playerid, vehicleAnglePosition);
    Vehicle[createdVehiclesCount][E_VEHICLE_MODEL_ID] = vehicleId;
    Vehicle[createdVehiclesCount][E_VEHICE_OWNER_ID] = playerid;
    Vehicle[createdVehiclesCount][E_VEHICE_OWNER_NAME] = GetPlayerUsername(playerid);
    Vehicle[createdVehiclesCount][E_CREATED_VEHICLE_ID] = AddStaticVehicle(vehicleId, vehicleXPosition, vehicleYPosition - 2, vehicleZPosition, vehicleAnglePosition, color[0], color[1]);
    SetVehicleLicensePlate(Vehicle[createdVehiclesCount][E_CREATED_VEHICLE_ID], vehicleLicensePlate);
    createdVehiclesCount++;

    format(message, sizeof(message), "{FFD700}Modelo do Ve�culo: {FFFFFF}%d {FFD700}- ID gerado do ve�culo: {FFFFFF}%d {FFD700}- Placa: {FFFFFF}%s{FFD700}.", vehicleId, createdVehiclesCount, vehicleLicensePlate);
    return SendClientMessage(playerid, -1, message);
  }

  new bool:isVehicleCreated = false;

  for(new i = 0; i < createdVehiclesCount; i++)
  {
    if(!strcmp(GetVehicleLicensePlate(Vehicle[i][E_CREATED_VEHICLE_ID]), vehicleLicensePlate))
    {
      isVehicleCreated = true;
    }
  }

  if(isVehicleCreated == true )
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}N�o foi poss�vel criar o ve�culo pois a placa j� existe.");
    return SendClientMessage(playerid, -1, message);
  }
    
  new Float:vehicleXPosition, Float:vehicleYPosition, Float:vehicleZPosition, Float:vehicleAnglePosition;

  GetPlayerPos(playerid, vehicleXPosition, vehicleYPosition, vehicleZPosition);
  GetPlayerFacingAngle(playerid, vehicleAnglePosition);
  Vehicle[createdVehiclesCount][E_VEHICLE_MODEL_ID] = vehicleId;
  Vehicle[createdVehiclesCount][E_VEHICE_OWNER_ID] = playerid;
  Vehicle[createdVehiclesCount][E_VEHICE_OWNER_NAME] = GetPlayerUsername(playerid);
  Vehicle[createdVehiclesCount][E_CREATED_VEHICLE_ID] = AddStaticVehicle(vehicleId, vehicleXPosition, vehicleYPosition - 2, vehicleZPosition, vehicleAnglePosition, color[0], color[1]);
  SetVehicleLicensePlate(Vehicle[createdVehiclesCount][E_CREATED_VEHICLE_ID], vehicleLicensePlate);
  createdVehiclesCount++;

  format(message, sizeof(message), "{FFD700}Modelo do ve�culo: {FFFFFF}%d {FFD700}- ID gerado do ve�culo: {FFFFFF}%d {FFD700}- Placa: {FFFFFF}%s{FFD700}.", vehicleId, createdVehiclesCount, vehicleLicensePlate);
  SendClientMessage(playerid, -1, message);

  return 1;
}

CMD:mostrarveiculos(playerid)
{
  new message[400];

  if(createdVehiclesCount == 0)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}N�o h� ve�culos para serem listados.");
    return SendClientMessage(playerid, -1, message);
  }

  for(new i = 0; i < createdVehiclesCount; i++)
  {
    format(message, sizeof(message), "%d - %d - %s - %d - %s - %d", Vehicle[i][E_VEHICLE_MODEL_ID], Vehicle[i][E_VEHICE_OWNER_ID], Vehicle[i][E_VEHICE_OWNER_NAME], Vehicle[i][E_CREATED_VEHICLE_ID], GetVehicleLicensePlate(Vehicle[i][E_CREATED_VEHICLE_ID]), Vehicle[i][E_IS_VEHICLE_TOWED]);
    SendClientMessage(playerid, -1, message);
  }

  return 1;
}

CMD:consultarveiculo(playerid, params[])
{
  new playerId, vehicleLicensePlate[9];
  new message[400];

  if(sscanf(params, "ds[9]", playerId, vehicleLicensePlate))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando inv�lido, por favor utilize: /consultarve�culo [ID do jogador] [placa do ve�culo].");
    return SendClientMessage(playerid, -1, message);
  }

  if(createdVehiclesCount == 0)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}N�o h� ve�culos para serem listados.");
    return SendClientMessage(playerid, -1, message);
  }

  new bool:isLicensePlateDifferent = false;
  new targetPlayerId = 0;

  for(new i = 0; i < createdVehiclesCount; i++)
  {
    if(Vehicle[i][E_VEHICE_OWNER_ID] != playerId && strcmp(GetVehicleLicensePlate(Vehicle[i][E_CREATED_VEHICLE_ID]), vehicleLicensePlate))
    { 
      isLicensePlateDifferent = true;
    }

    targetPlayerId = i;
  }

  if(isLicensePlateDifferent == true)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}N�o foi poss�vel encontrar o ve�culo com o ID do jogador e placa do ve�culo informados.");
    return SendClientMessage(playerid, -1, message);
  }

  format(message, sizeof(message), "{FF0000}+{FFD700}-----------------------------------{FF0000}+\n{00FF00}Modelo: {FFFFFF}%d{00FF00}.\n{00FF00}ID do dono: {FFFFFF}%d{00FF00}.\n{00FF00}Nome do dono: {FFFFFF}%s{00FF00}.\n{00FF00}ID do ve�culo: {FFFFFF}%d{00FF00}.\n{00FF00}Placa do ve�culo: {FFFFFF}%s{00FF00}.\n{FF0000}+{FFD700}-----------------------------------{FF0000}+", Vehicle[targetPlayerId][E_VEHICLE_MODEL_ID], Vehicle[targetPlayerId][E_VEHICE_OWNER_ID], Vehicle[targetPlayerId][E_VEHICE_OWNER_NAME], Vehicle[targetPlayerId][E_CREATED_VEHICLE_ID], GetVehicleLicensePlate(Vehicle[targetPlayerId][E_CREATED_VEHICLE_ID]));
  ShowPlayerDialog(playerid, 5, DIALOG_STYLE_MSGBOX, "DETRAN - Consulta de ve�culo", message, "Fechar", "");

  return 1;
}

CMD:rebocar(playerid, params[])
{
  new vehicleLicensePlate[9];
  new message[150];

  if(sscanf(params, "s[9]", vehicleLicensePlate))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Comando inv�lido, por favor utilize: /rebocar [placa do ve�culo].");
    return SendClientMessage(playerid, -1, message);
  }

  if(!IsPlayerInAnyVehicle(playerid))
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Voc� precisa estar em um ve�culo para utilizar este comando.");
    return SendClientMessage(playerid, -1, message);
  }

  if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 578)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}Voc� s� pode rebocar um carro utilizando o DFT-30.");
    return SendClientMessage(playerid, -1, message);
  }

  new bool:isLicensePlateEqual = false;
  new bool:targetPlayerId = 0;

  for(new i = 0; i < createdVehiclesCount; i++)
  {
    if(!strcmp(GetVehicleLicensePlate(Vehicle[i][E_CREATED_VEHICLE_ID]), vehicleLicensePlate))
    {
      isLicensePlateEqual = true;
      targetPlayerId = i;
    }
  }

  if(isLicensePlateEqual == false)
  {
    format(message, sizeof(message), "{FF0000}[ERRO] {FFD700}N�o foi poss�vel encontrar o ve�culo com a placa informada.");
    return SendClientMessage(playerid, -1, message);
  }

  towMessage[playerid] = CreatePlayerTextDraw(playerid, 320.0, 240.0, "Rebocando... Aguarde.");
  PlayerTextDrawAlignment(playerid, towMessage[playerid], 2);
  PlayerTextDrawFont(playerid, towMessage[playerid], 3);
  PlayerTextDrawLetterSize(playerid, towMessage[playerid], 0.8, 2.0);
  PlayerTextDrawSetOutline(playerid, towMessage[playerid], 1);
  PlayerTextDrawColor(playerid, towMessage[playerid], 0xFF9900FF);
  PlayerTextDrawShow(playerid, towMessage[playerid]);

  SetTimerEx("TowVehicle", 3000, false, "dd", targetPlayerId, playerid);

  return 1;
}

#endif
