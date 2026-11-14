<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AnimalController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SolicitacaoAdocaoController;
use App\Http\Controllers\Api\FavoritoController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::apiResource('animais', AnimalController::class)->only(['index', 'show'])->parameters(['animais' => 'id']);
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('animais', AnimalController::class)->only(['store', 'update', 'destroy'])->parameters(['animais' => 'id']);
    Route::apiResource('solicitacoes-adocao', SolicitacaoAdocaoController::class)->parameters(['solicitacoes-adocao' => 'id']);
    Route::apiResource('favoritos', FavoritoController::class)->only(['index', 'store', 'destroy']);;
    Route::post('/logout', [AuthController::class, 'logout']);
});
