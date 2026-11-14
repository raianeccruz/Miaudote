<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AuthController extends Controller
{
    public function __construct(
        protected AuthService $authService
    ) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $dados = $request->validated();

        $resultado = $this->authService->cadastrar($dados);

        return response()->json($resultado, 201);
    }

    public function login(LoginRequest $request)
    {
        $dados = $request->validated();

        $resultado = $this->authService->login($dados);

        return response()->json($resultado, 200);
    }

    public function logout(Request $request)
    {
        $user = $request->user();

        $this->authService->logout($user);

        return response()->json(['message' => 'Logout realizado com sucesso.'], 200);
    }
}