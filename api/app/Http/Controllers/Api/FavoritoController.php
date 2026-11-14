<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Http\Requests\FavoritoStoreRequest;
use App\Http\Resources\FavoritoResource;
use App\Services\FavoritoService;

class FavoritoController extends Controller
{
    public function __construct(
        protected FavoritoService $service
    ) {}

    // Lista os favoritos do usuário autenticado.
    public function index(Request $request)
    {
        $favoritos = $this->service->listar($request->user());

        return FavoritoResource::collection($favoritos);
    }

    // Adiciona um animal aos favoritos.
    public function store(FavoritoStoreRequest $request)
    {
        $favorito = $this->service->criar($request->user(), $request->validated()['animal_id']);

        return (new FavoritoResource($favorito))->response()->setStatusCode(201);
    }

    // Remove um favorito.
    public function destroy(Request $request, int $id)
    {
        $this->service->remover($request->user(), $id);

        return response()->json([
            'message' => 'Favorito removido com sucesso.',
        ]);
    }
}
