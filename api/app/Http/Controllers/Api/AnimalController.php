<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AnimalStoreRequest;
use App\Http\Requests\AnimalUpdateRequest;
use App\Http\Resources\AnimalResource;
use Illuminate\Http\Request;
use App\Services\AnimalService;
use Illuminate\Http\JsonResponse;

class AnimalController extends Controller
{
    public function __construct(protected AnimalService $animalService) 
    {}

    public function index()
    {
        $animais = $this->animalService->listar();

        return AnimalResource::collection($animais);
    }

    public function store(AnimalStoreRequest $request): JsonResponse
    {
        $user = $request->user(); // Obtém o usuário autenticado
        $animal = $this->animalService->criar($user, $request->validated());

        return (new AnimalResource($animal))
            ->response()
            ->setStatusCode(201);
    }

    public function show(int $id)
    {
        $animal = $this->animalService->buscarPorId($id);

        return new AnimalResource($animal);
    }

    public function update(AnimalUpdateRequest $request, int $id)
    {
        $user = $request->user(); // Obtém o usuário autenticado
        $this->animalService->buscarDoUsuario($id, $user->id); // Verifica se o animal pertence ao usuário autenticado
        $animal = $this->animalService->atualizar($id, $request->validated());

        return new AnimalResource($animal);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user(); // Obtém o usuário autenticado
        $this->animalService->buscarDoUsuario($id, $user->id); // Verifica se o animal pertence ao usuário autenticado
        $this->animalService->deletar($id);

        return response()->json(['message' => 'Animal deletado com sucesso.']);
    }
}