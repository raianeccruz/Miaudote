<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SolicitacaoAdocaoStoreRequest;
use App\Http\Requests\SolicitacaoAdocaoUpdateRequest;
use App\Http\Resources\SolicitacaoAdocaoResource;
use App\Services\SolicitacaoAdocaoService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SolicitacaoAdocaoController extends Controller
{
    public function __construct(
        protected SolicitacaoAdocaoService $service
    ) {}

    public function index(Request $request)
    {
        $solicitacoes = $this->service->listar($request->user());

        return SolicitacaoAdocaoResource::collection($solicitacoes);
    }

    public function store(SolicitacaoAdocaoStoreRequest $request): JsonResponse {
        $solicitacao = $this->service->criar($request->user(), $request->validated()['animal_id']);

        return (new SolicitacaoAdocaoResource($solicitacao))->response()->setStatusCode(201);
    }

    public function show(int $id, Request $request)
    {
        $solicitacao = $this->service->buscar($id);

        $user = $request->user();

        $solicitante = $solicitacao->user_id === $user->id;

        $responsavel = $solicitacao->animal->user_id === $user->id;

        abort_unless($solicitante || $responsavel, 403, 'Você não tem permissão para visualizar esta solicitação.');

        return new SolicitacaoAdocaoResource($solicitacao);
    }

    public function update(SolicitacaoAdocaoUpdateRequest $request, int $id) 
    {
        $solicitacao = $this->service->atualizarStatus($request->user(), $id, $request->validated()['status']);

        return new SolicitacaoAdocaoResource($solicitacao);
    }

    public function destroy(Request $request, int $id)
    {
        $solicitacao = $this->service->cancelar($request->user(), $id);

        return new SolicitacaoAdocaoResource($solicitacao);
    }
}