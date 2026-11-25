//
//  PresenterTests.swift
//  ChallengeFinalTests
//
//  Created by Paulo Henrique Costa Alves on 19/10/26.
//

import Foundation
import Testing
import SwiftData
import UIKit
@testable import ChallengeFinal

@Suite("Tests for all presenters in the project")
@MainActor
struct PresenterTests {
    
    // MARK: - Auxiliadores
    
    // O presenter guarda o store como weak, então o teste precisa segurar o store (por isso devolvemos os dois).
    private func createPresenterAndStore() -> (presenter: HomePresenter, store: HomeStore) {
        let store = HomeStore(coordinator: HomeCoordinator())
        let presenter = HomePresenter(store: store)
        return (presenter, store)
    }
    
    // MARK: - HomePresenter
    
    @Test func testingPresentCategoryUpdatesStore() {
        let (presenter, store) = createPresenterAndStore()
        
        presenter.presentCategory(.cognitive)
        
        #expect(store.currentCategory == .cognitive)
        
        presenter.presentCategory(.physical)
        
        #expect(store.currentCategory == .physical)
    }
    
    @Test func testingPresentWeekUpdatesStore() {
        let (presenter, store) = createPresenterAndStore()
        
        // 18/10/2026 é domingo, então a semana vai de domingo a sábado.
        let calendar = Calendar.current
        let sunday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 18))!
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }.map { (date: $0, humor: Humor?.none) }
        
        presenter.presentWeek(days: days)
        
        #expect(store.daysOfWeek.map(\.label) == ["D", "S", "T", "Q", "Q", "S", "S"])
    }
    
    // A semana depende da data atual, então montamos os dias relativos a hoje (ontem, hoje, amanhã).
    private func yesterdayTodayTomorrow() throws -> (yesterday: Date, today: Date, tomorrow: Date) {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        return (yesterday, today, tomorrow)
    }
    
    @Test func testingPresentWeekKeepsHumorOnPastAndTodayButDropsFuture() throws {
        let (presenter, store) = createPresenterAndStore()
        let (yesterday, today, tomorrow) = try yesterdayTodayTomorrow()
        
        presenter.presentWeek(days: [
            (date: yesterday, humor: .veryPleasant),
            (date: today, humor: .neutral),
            (date: tomorrow, humor: .pleasant)
        ])
        
        // Ontem e hoje mantêm o humor; amanhã é descartado.
        #expect(store.daysOfWeek.map(\.humor) == [.veryPleasant, .neutral, nil])
    }
    
    @Test func testingPresentWeekMarksOnlyDaysAfterTodayAsFuture() throws {
        let (presenter, store) = createPresenterAndStore()
        let (yesterday, today, tomorrow) = try yesterdayTodayTomorrow()
        
        presenter.presentWeek(days: [
            (date: yesterday, humor: nil),
            (date: today, humor: nil),
            (date: tomorrow, humor: nil)
        ])
        
        #expect(store.daysOfWeek.map(\.isFuture) == [false, false, true])
    }
    
    @Test func testingPresentWeekMarksOnlyTodayAsToday() throws {
        let (presenter, store) = createPresenterAndStore()
        let (yesterday, today, tomorrow) = try yesterdayTodayTomorrow()
        
        presenter.presentWeek(days: [
            (date: yesterday, humor: nil),
            (date: today, humor: nil),
            (date: tomorrow, humor: nil)
        ])
        
        #expect(store.daysOfWeek.map(\.isToday) == [false, true, false])
    }
    
    // MARK: - ActivityPresenter (sorteio de desafios)
    
    // Mesmo cuidado do Home: o presenter guarda o store como weak, então o teste segura o store.
    private func createActivityPresenterAndStore() -> (presenter: ActivityPresenter, store: ActivityStore) {
        let coordinator = ActivityCoordinator(selectedCategory: .physical, onFinish: {})
        let store = ActivityStore(coordinator: coordinator)
        let presenter = ActivityPresenter(store: store)
        return (presenter, store)
    }
    
    // SwiftData precisa de um container carregado para criar o `ActivityResult`.
    let modelContainer: ModelContainer = {
        let schema = Schema([Activity.self, ActivityResult.self, Profile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()
    
    @Test func testingPresentRestoredChallengeFillsStoreWithoutMarkingReady() {
        let (presenter, store) = createActivityPresenterAndStore()

        presenter.presentRestoredChallenge(title: "respire fundo", subtitle: "Pausa", description: "Respire por um minuto.")

        #expect(store.activityTitle == "respire fundo")
        #expect(store.activitySubtitle == "Pausa")
        #expect(store.activityDescription == "Respire por um minuto.")
        #expect(store.isChallengeReady == false)
    }

    @Test func testingPresentSearchingMarksStoreAsSearching() {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentSearching()
        
        #expect(store.isSearching == true)
    }
    
    @Test func testingPresentChallengeFillsStoreAndMarksReady() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentSearching()
        let challenge = FrictionChallenge(title: "respire fundo", subTitle: "Pausa", rationale: "Respire por um minuto.")
        
        presenter.presentActivity(challenge)
        
        #expect(store.activityTitle == "respire fundo")
        #expect(store.activitySubtitle == "Pausa")
        #expect(store.activityDescription == "Respire por um minuto.")
        #expect(store.isChallengeReady == true)
        #expect(store.isSearching == false)
    }
    
    @Test func testingPresentSearchFailedStopsSearchingWithoutChallenge() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentSearching()
        
        presenter.presentSearchFailed()
        
        #expect(store.isSearching == false)
        #expect(store.isChallengeReady == false)
        #expect(store.activityTitle == nil)
    }
    
    @Test func testingPresentAcceptedActivityMarksChallengeAsAccepted() {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentAcceptedActivity()
        
        #expect(store.isChallengeAccepted == true)
    }
    
    @Test func testingPresentStartAgainClearsRaffleState() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentActivity(FrictionChallenge(title: "t", subTitle: "s", rationale: "r"))
        presenter.presentAcceptedActivity()
        
        presenter.presentStartAgain()
        
        #expect(store.isChallengeReady == false)
        #expect(store.isChallengeAccepted == false)
        #expect(store.isSearching == false)
    }
    
    // MARK: ActivityPresenter (cronômetro)
    
    // Cada par é (segundos recebidos do Interactor, texto esperado na Store).
    @Test(arguments: [
        (TimeInterval(0), "00:00:00"),
        (TimeInterval(5), "00:00:05"),
        (TimeInterval(65), "00:01:05"),
        (TimeInterval(3725), "01:02:05"),
        (TimeInterval(36000), "10:00:00"),
        (TimeInterval(59.9), "00:00:59")
    ])
    func testingPresentTimeFormatsHoursMinutesAndSeconds(elapsed: TimeInterval, expected: String) {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentTime(elapsed)
        
        #expect(store.timeText == expected)
    }
    
    @Test func testingPresentTimeReplacesPreviousTime() {
        let (presenter, store) = createActivityPresenterAndStore()
        presenter.presentTime(3725)
        
        presenter.presentTime(0)
        
        #expect(store.timeText == "00:00:00")
    }
    
    // MARK: ActivityPresenter (humor)
    
    @Test func testingPresentHumorUpdatesStore() {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentHumor(.veryUnpleasant)
        
        #expect(store.humor == .veryUnpleasant)
    }

    // MARK: ActivityPresenter (conquista)

    // A conquista chega pronta do Interactor: o Presenter só a entrega à Store e abre o summary.
    @Test func testingPresentSummaryPassesAchievementToStoreAndOpensSummary() {
        let (presenter, store) = createActivityPresenterAndStore()

        presenter.presentSummary(achievement: Achievement(title: "mestre offline", description: "você passou 1h offline"))

        #expect(store.achievementTitle == "mestre offline")
        #expect(store.achievementDescription == "você passou 1h offline")
        #expect(store.currentStep == .summary)
    }

    // MARK: ActivityPresenter (compartilhamento)
    
    @Test func testingPresentStoryRendersStoryImage() throws {
        let (presenter, store) = createActivityPresenterAndStore()
        let result = ActivityResult(time: 0, humor: .veryPleasant)

        presenter.presentStory(result, title: "faça o seu cardio", subtitle: "menos distração", description: "sem redes sociais", challengeIcon: ActivityCategory.physical.defaultClosed)
        
        // O story sai no tamanho da especificação (pontos x scale).
        let image = try #require(store.storyImages[.white])
        #expect(image.size.width * image.scale == ShareImageSpecification.pointSize.width * ShareImageSpecification.scale)
        #expect(image.size.height * image.scale == ShareImageSpecification.pointSize.height * ShareImageSpecification.scale)
    }
    
    @Test func testingPresentStoryWithoutPhotoRendersEveryStyleExceptPhoto() {
        let (presenter, store) = createActivityPresenterAndStore()
        let result = ActivityResult(time: 0, humor: .veryPleasant)

        presenter.presentStory(result, title: "faça o seu cardio", subtitle: "menos distração", description: "sem redes sociais", challengeIcon: ActivityCategory.physical.defaultClosed)
        
        #expect(Set(store.storyImages.keys) == [.white, .black, .transparent])
    }
    
    @Test func testingPresentStoryWithPhotoRendersEveryStyle() {
        let (presenter, store) = createActivityPresenterAndStore()
        let result = ActivityResult(photo: makePhotoData(), time: 0, humor: .veryPleasant)

        presenter.presentStory(result, title: "faça o seu cardio", subtitle: "menos distração", description: "sem redes sociais", challengeIcon: ActivityCategory.physical.defaultClosed)
        
        #expect(Set(store.storyImages.keys) == Set(StoryCardStyle.allCases))
    }
    
    @Test func testingPresentShareSheetOpensAndCloses() {
        let (presenter, store) = createActivityPresenterAndStore()
        let url = URL(fileURLWithPath: "/tmp/Desafio-Concluído.png")
        
        presenter.presentShareSheet(fileURL: url)
        #expect(store.shareItem?.activityItems.first as? URL == url)
        
        presenter.presentShareFinished(completed: true)
        #expect(store.shareItem == nil)
    }
    
    @Test func testingPresentShareErrorShowsMessage() {
        let (presenter, store) = createActivityPresenterAndStore()
        
        presenter.presentError(ShareError.renderFailed)
        
        #expect(store.errorMessage == "Não foi possível preparar a imagem para compartilhar. Tente novamente.")
    }
    // MARK: - FeelingsPresenter (agrupar por humor)
    
    // Mesmo cuidado dos outros: o presenter guarda o store como weak, então o teste segura o store.
    private func createFeelingsPresenterAndStore() -> (presenter: FeelingsPresenter, store: FeelingsStore) {
        let store = FeelingsStore()
        let presenter = FeelingsPresenter(store: store)
        return (presenter, store)
    }
    
    /// `humor == nil` cria a atividade sem `ActivityResult`.
    private func makeFeelingActivity(named name: String, humor: Humor?) -> Activity {
        let result = humor.map { ActivityResult(time: 10, humor: $0) }
        return Activity(category: .physical, result: result, name: name, description: "-", archived: false)
    }
    
    @Test func testingPresentFeelingsLoadedGroupsActivitiesByHumor() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activities = [
            makeFeelingActivity(named: "A", humor: .pleasant),
            makeFeelingActivity(named: "B", humor: .veryPleasant),
            makeFeelingActivity(named: "C", humor: .pleasant)
        ]
        
        presenter.presentFeelingsLoaded(activities: activities)
        
        // A ordem original é mantida dentro de cada grupo.
        #expect(store.feelings[.pleasant]?.map(\.activity.name) == ["A", "C"])
        #expect(store.feelings[.veryPleasant]?.map(\.activity.name) == ["B"])
        #expect(store.feelings.count == 2)
    }
    
    @Test func testingPresentFeelingsLoadedLeavesOutHumorsWithoutActivities() {
        let (presenter, store) = createFeelingsPresenterAndStore()

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: .pleasant)])

        // A View usa `?? 0` para esses humores.
        #expect(store.feelings[.unpleasant] == nil)
        #expect(store.feelings[.veryUnpleasant] == nil)
    }
    
    @Test func testingPresentFeelingsLoadedWithNoActivitiesLeavesStoreEmpty() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentFeelingsLoaded(activities: [])
        
        #expect(store.feelings.isEmpty)
    }
    
    @Test func testingPresentFeelingsLoadedIgnoresActivitiesWithoutResult() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activities = [
            makeFeelingActivity(named: "Sem resultado", humor: nil),
            makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        ]
        
        presenter.presentFeelingsLoaded(activities: activities)
        
        #expect(store.feelings.count == 1)
        #expect(store.feelings[.pleasant]?.map(\.activity.name) == ["Caminhada"])
    }
    
    @Test func testingPresentFeelingsLoadedKeepsTheSameActivityInstances() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant)

        presenter.presentFeelingsLoaded(activities: [activity])

        #expect(store.feelings[.pleasant]?.first?.activity === activity)
    }
    
    @Test(arguments: Humor.allCases)
    func testingPresentFeelingsLoadedUsesActivityHumorAsKey(humor: Humor) {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: humor)])
        
        #expect(Array(store.feelings.keys) == [humor])
    }
    
    // Cada carga substitui a anterior, não soma.
    @Test func testingPresentFeelingsLoadedReplacesPreviousFeelings() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: .pleasant)])

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "B", humor: .veryPleasant)])

        #expect(store.feelings[.pleasant] == nil)
        #expect(store.feelings[.veryPleasant]?.map(\.activity.name) == ["B"])
    }
    
    // O store é weak: se a tela já foi embora, apresentar não pode quebrar.
    @Test func testingPresentFeelingsLoadedWithoutStoreDoesNotCrash() {
        let presenter: FeelingsPresenter
        do {
            let store = FeelingsStore()
            presenter = FeelingsPresenter(store: store)
        }

        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "A", humor: .pleasant)])

        #expect(presenter.store == nil)
    }
    
    // MARK: - FeelingsPresenter (foto de cada atividade)
    
    /// Bytes de uma imagem válida (PNG 4x4), como a câmera entregaria.
    private func makePhotoData() -> Data {
        UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
            .image { context in
                UIColor.red.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
            }
            .pngData()!
    }
    
    private func makeFeelingActivity(named name: String, humor: Humor, photo: Data?) -> Activity {
        let activity = makeFeelingActivity(named: name, humor: humor)
        activity.result?.photo = photo
        return activity
    }
    
    // A conversão acontece aqui, uma vez, para a lista só mostrar.
    @Test func testingPresentFeelingsLoadedConvertsPhotoDataToImage() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant, photo: makePhotoData())
        
        presenter.presentFeelingsLoaded(activities: [activity])
        
        #expect(store.feelings[.pleasant]?.first?.image != nil)
    }
    
    @Test func testingPresentFeelingsLoadedWithoutPhotoHasNoImage() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentFeelingsLoaded(activities: [makeFeelingActivity(named: "Caminhada", humor: .pleasant)])
        
        #expect(store.feelings[.pleasant]?.count == 1)
        #expect(store.feelings[.pleasant]?.first?.image == nil)
    }
    
    // Bytes que não formam uma imagem não derrubam a lista: o card só fica sem foto.
    @Test func testingPresentFeelingsLoadedWithInvalidPhotoDataHasNoImage() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant, photo: Data([1, 2, 3]))
        
        presenter.presentFeelingsLoaded(activities: [activity])
        
        #expect(store.feelings[.pleasant]?.first?.image == nil)
    }
    
    // Cada atividade fica com a sua própria foto.
    @Test func testingPresentFeelingsLoadedKeepsEachImageWithItsActivity() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let withPhoto = makeFeelingActivity(named: "Com foto", humor: .pleasant, photo: makePhotoData())
        let withoutPhoto = makeFeelingActivity(named: "Sem foto", humor: .pleasant)
        
        presenter.presentFeelingsLoaded(activities: [withPhoto, withoutPhoto])
        
        let entries = store.feelings[.pleasant] ?? []
        #expect(entries.first(where: { $0.activity === withPhoto })?.image != nil)
        #expect(entries.first(where: { $0.activity === withoutPhoto })?.image == nil)
    }
    
    @Test func testingImageFromValidDataIsNotNil() {
        let (presenter, _) = createFeelingsPresenterAndStore()
        
        #expect(presenter.image(from: makePhotoData()) != nil)
    }
    
    @Test func testingImageFromNilOrInvalidDataIsNil() {
        let (presenter, _) = createFeelingsPresenterAndStore()
        
        #expect(presenter.image(from: nil) == nil)
        #expect(presenter.image(from: Data([1, 2, 3])) == nil)
    }
    
    // MARK: - FeelingsPresenter (detalhe)
    
    @Test func testingPresentSelectedActivityOpensDetailWithPhotoAndStory() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant, photo: makePhotoData())
        
        presenter.presentSelectedActivity(activity: activity)
        
        #expect(store.presentDetail)
        #expect(store.selectedActivity === activity)
        #expect(store.selectedPhoto != nil)
        #expect(store.storyImages[.photo] != nil)
    }
    
    @Test func testingPresentSelectedActivityWithoutPhotoStillRendersStory() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentSelectedActivity(activity: makeFeelingActivity(named: "Caminhada", humor: .pleasant))
        
        #expect(store.selectedPhoto == nil)
        #expect(store.storyImages[.white] != nil)
        #expect(store.storyImages[.photo] == nil)
    }
    
    // MARK: - FeelingsPresenter (tirar outra foto)
    
    @Test func testingPresentCameraOpensCameraAndClearsError() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        store.presentError("antigo")
        
        presenter.presentCamera()
        
        #expect(store.isCameraPresented)
        #expect(store.errorMessage == nil)
    }
    
    @Test func testingPresentCameraClosedClosesCamera() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentCamera()
        
        presenter.presentCameraClosed()
        
        #expect(store.isCameraPresented == false)
    }
    
    @Test func testingPresentPermissionDeniedClosesCameraAndShowsMessage() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentCamera()
        
        presenter.presentPermissionDenied()
        
        #expect(store.isCameraPresented == false)
        #expect(store.errorMessage?.isEmpty == false)
    }
    
    @Test(arguments: [(true, "bolt.fill"), (false, "bolt.slash")])
    func testingPresentFlashChoosesIcon(isOn: Bool, icon: String) {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentFlash(isOn: isOn)
        
        #expect(store.cameraFlashIcon == icon)
    }
    
    @Test func testingPresentPhotoUpdatedShowsNewPhotoAndClosesCamera() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentCamera()
        
        presenter.presentPhotoUpdated(makePhotoData())
        
        #expect(store.selectedPhoto != nil)
        #expect(store.isCameraPresented == false)
        #expect(store.errorMessage == nil)
    }
    
    @Test func testingPresentPhotoUpdatedWithInvalidDataShowsErrorAndKeepsOldPhoto() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant, photo: makePhotoData())
        presenter.presentSelectedActivity(activity: activity)
        presenter.presentCamera()
        
        presenter.presentPhotoUpdated(Data([1, 2, 3]))
        
        #expect(store.selectedPhoto != nil)
        #expect(store.isCameraPresented == false)
        #expect(store.errorMessage?.isEmpty == false)
    }
    
    // A foto trocada também aparece no card da lista, sem recarregar tudo.
    @Test func testingPresentPhotoUpdatedRefreshesTheListCard() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        presenter.presentFeelingsLoaded(activities: [activity])
        presenter.presentSelectedActivity(activity: activity)
        #expect(store.feelings[.pleasant]?.first?.image == nil)
        
        presenter.presentPhotoUpdated(makePhotoData())
        
        #expect(store.feelings[.pleasant]?.first?.image != nil)
    }
    
    @Test(arguments: [
        CameraError.deviceUnavailable,
        CameraError.sessionNotRunning,
        CameraError.configurationFailed,
        CameraError.captureFailed
    ])
    func testingPresentErrorTranslatesCameraErrorsToMessage(error: CameraError) {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentError(error)
        
        #expect(store.errorMessage?.isEmpty == false)
    }
    
    // Toque duplo no disparo não é problema do usuário: nenhum alerta.
    @Test func testingPresentErrorIgnoresCaptureInProgress() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentError(CameraError.captureInProgress)
        
        #expect(store.errorMessage == nil)
    }
    
    @Test func testingPresentErrorTranslatesShareAndLibraryErrors() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentError(ShareError.renderFailed)
        let shareMessage = store.errorMessage
        presenter.presentError(PhotoLibraryError.loadFailed)
        
        #expect(shareMessage == "Não foi possível preparar a imagem para compartilhar. Tente novamente.")
        #expect(store.errorMessage == "Não foi possível carregar a foto da galeria. Tente outra.")
    }
    
    @Test(arguments: [true, false])
    func testingPresentDetailVisibilityShowsOrHidesDetailKeepingActivity(isVisible: Bool) {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let activity = makeFeelingActivity(named: "Caminhada", humor: .pleasant)
        presenter.presentSelectedActivity(activity: activity)
        
        presenter.presentDetailVisibility(isVisible: isVisible)
        
        #expect(store.presentDetail == isVisible)
        #expect(store.selectedActivity === activity)
    }
    
    @Test func testingPresentAlertsDismissedClearsError() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentError(CameraError.captureFailed)
        
        presenter.presentAlertsDismissed()
        
        #expect(store.errorMessage == nil)
    }
    
    // MARK: - FeelingsPresenter (compartilhar)
    
    @Test func testingPresentStoryRendersImageForActivity() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        
        presenter.presentStory(for: makeFeelingActivity(named: "Caminhada", humor: .pleasant, photo: makePhotoData()))
        
        #expect(Set(store.storyImages.keys) == Set(StoryCardStyle.allCases))
    }
    
    @Test func testingPresentShareSheetOpensSheetWithFileAndClearsError() {
        let (presenter, store) = createFeelingsPresenterAndStore()
        let url = URL(fileURLWithPath: "/tmp/story.png")
        presenter.presentError(CameraError.captureFailed)
        
        presenter.presentShareSheet(fileURL: url)
        
        #expect(store.shareItem?.activityItems.first as? URL == url)
        #expect(store.errorMessage == nil)
    }
    
    @Test(arguments: [true, false])
    func testingPresentShareFinishedClosesSheet(completed: Bool) {
        let (presenter, store) = createFeelingsPresenterAndStore()
        presenter.presentShareSheet(fileURL: URL(fileURLWithPath: "/tmp/story.png"))
        
        presenter.presentShareFinished(completed: completed)
        
        #expect(store.shareItem == nil)
    }
    
    // MARK: - ChallengesPresenter (listagem e estados vazios)
    
    // Mesmo cuidado dos outros: o presenter guarda o store como weak, então o teste segura o store.
    private func createChallengesPresenterAndStore() -> (presenter: ChallengesPresenter, store: ChallengesStore) {
        let store = ChallengesStore()
        let presenter = ChallengesPresenter(store: store)
        return (presenter, store)
    }
    
    private func makeChallenge(named name: String, photo: Data? = nil) -> Activity {
        let result = ActivityResult(photo: photo, time: 10, humor: .pleasant)
        return Activity(category: .physical, result: result, name: name, description: "-", archived: false)
    }
    
    @Test func testingPresentChallengesWithActivitiesHasNoEmptyState() {
        let (presenter, store) = createChallengesPresenterAndStore()
        let walk = makeChallenge(named: "Caminhada")
        
        presenter.presentChallenges([walk], selectedCategory: .physical, hasCompletedChallenges: true)
        
        #expect(store.challenges.count == 1)
        #expect(store.challenges.first === walk)
        #expect(store.selectedCategory == .physical)
        #expect(store.emptyState == nil)
    }
    
    // Nunca concluiu nada: convida a ir para a Home.
    @Test func testingPresentChallengesWithoutCompletedShowsNoCompleted() {
        let (presenter, store) = createChallengesPresenterAndStore()
        
        presenter.presentChallenges([], selectedCategory: nil, hasCompletedChallenges: false)
        
        #expect(store.challenges.isEmpty)
        #expect(store.emptyState == .noCompleted)
    }
    
    // Tem concluídos, mas a busca/filtro não achou nada.
    @Test func testingPresentChallengesWithFilterWithoutMatchesShowsNoResults() {
        let (presenter, store) = createChallengesPresenterAndStore()
        
        presenter.presentChallenges([], selectedCategory: .social, hasCompletedChallenges: true)
        
        #expect(store.emptyState == .noResults)
        #expect(store.selectedCategory == .social)
    }
    
    @Test func testingPresentChallengesReplacesPreviousEmptyState() {
        let (presenter, store) = createChallengesPresenterAndStore()
        presenter.presentChallenges([], selectedCategory: nil, hasCompletedChallenges: false)
        
        presenter.presentChallenges([makeChallenge(named: "Caminhada")], selectedCategory: nil, hasCompletedChallenges: true)
        
        #expect(store.emptyState == nil)
        #expect(store.challenges.count == 1)
    }
    
    // MARK: ChallengesPresenter (arquivados)
    
    @Test func testingPresentArchivedChallengesWithItemsHasNoEmptyState() {
        let (presenter, store) = createChallengesPresenterAndStore()
        
        presenter.presentArchivedChallenges([makeChallenge(named: "Arquivada")])
        
        #expect(store.archivedChallenges.map(\.name) == ["Arquivada"])
        #expect(store.archivedEmptyState == nil)
    }
    
    @Test func testingPresentArchivedChallengesEmptyShowsNoArchived() {
        let (presenter, store) = createChallengesPresenterAndStore()
        
        presenter.presentArchivedChallenges([])
        
        #expect(store.archivedChallenges.isEmpty)
        #expect(store.archivedEmptyState == .noArchived)
    }
    
    @Test(arguments: [true, false])
    func testingPresentArchivedSheetForwardsVisibility(isPresented: Bool) {
        let (presenter, store) = createChallengesPresenterAndStore()
        
        presenter.presentArchivedSheet(isPresented: isPresented)
        
        #expect(store.isArchivedPresented == isPresented)
    }
    
    // MARK: ChallengesPresenter (resumo)
    
    @Test func testingPresentSummaryConvertsPhotoToImage() {
        let (presenter, store) = createChallengesPresenterAndStore()
        let activity = makeChallenge(named: "Caminhada", photo: makePhotoData())
        
        presenter.presentSummary(activity)
        
        #expect(store.selectedChallenge === activity)
        #expect(store.selectedPhoto != nil)
    }
    
    @Test func testingPresentSummaryWithoutPhotoHasNoImage() {
        let (presenter, store) = createChallengesPresenterAndStore()
        let activity = makeChallenge(named: "Caminhada")

        presenter.presentSummary(activity)

        #expect(store.selectedChallenge === activity)
        #expect(store.selectedPhoto == nil)
    }
    
    // MARK: ChallengesPresenter (reflita)

    @Test func testingChallengesPresentHumorAndMoodForwardToStore() {
        let (presenter, store) = createChallengesPresenterAndStore()

        presenter.presentHumor(.pleasant)
        presenter.presentMood(isPresented: true)

        #expect(store.reflectionHumor == .pleasant)
        #expect(store.isMoodPresented)

        presenter.presentMood(isPresented: false)

        #expect(store.isMoodPresented == false)
    }

    // MARK: - ProfilePresenter

    // Mesmo cuidado dos outros: o presenter guarda o store como weak, então o teste segura o store.
    private func createProfilePresenterAndStore() -> (presenter: ProfilePresenter, store: ProfileStore) {
        let store = ProfileStore()
        let presenter = ProfilePresenter(store: store)
        return (presenter, store)
    }

    @Test func testingPresentProfileFillsNamePhotoAndSettings() {
        let (presenter, store) = createProfilePresenterAndStore()
        let profile = Profile(profilePicture: makePhotoData(), name: "Raquel", notifications: true,
                              localizable: false, backgroundActivity: true, streak: 0)

        presenter.presentProfile(profile)

        #expect(store.name == "Raquel")
        #expect(store.userPhoto != nil)
        #expect(store.localizable == false)
        #expect(store.notifications == true)
        #expect(store.backgroundActivity == true)
    }

    // Sem nome ainda: mostra o placeholder do protótipo.
    @Test func testingPresentProfileWithoutNameShowsPlaceholder() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentProfile(Profile(name: ""))

        #expect(store.name == "nome")
    }

    @Test func testingPresentProfileWithoutOrInvalidPhotoHasNoImage() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentProfile(Profile(profilePicture: nil))
        #expect(store.userPhoto == nil)

        presenter.presentProfile(Profile(profilePicture: Data([1, 2, 3])))
        #expect(store.userPhoto == nil)
    }

    @Test func testingPresentProfileFillsStreakCard() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentProfile(Profile(streak: 7))

        #expect(store.streakText == "07 dias")
        #expect(store.levelTitle == "lenda da consistência")
        #expect(store.levelSubtitle == "07 dias priorizando seu bem estar!")
    }

    // Cada par é (dias seguidos, texto do card). Dois dígitos e singular no 1.
    @Test(arguments: [
        (0, "0 dias"),
        (1, "01 dia"),
        (3, "03 dias"),
        (15, "15 dias"),
        (120, "120 dias")
    ])
    
    func testingStreakText(streak: Int, expected: String) {
        let (presenter, _) = createProfilePresenterAndStore()

        #expect(presenter.streakText(for: streak) == expected)
    }
    
    // Vale o último marco já alcançado; depois do último, ele vale para sempre.
    @Test(arguments: [
        (0, "começando :)"),
        (2, "começando :)"),
        (3, "pegou o ritmo"),
        (6, "pegou o ritmo"),
        (7, "lenda da consistência"),
        (15, "virou rotina"),
        (19, "virou rotina"),
        (20, "nova era?"),
        (30, "ícone faz assim!"),
        (365, "ícone faz assim!")
    ])
    
    func testingMilestoneForStreak(streak: Int, expectedTitle: String) {
        let (presenter, _) = createProfilePresenterAndStore()

        #expect(presenter.milestone(for: streak).title == expectedTitle)
    }

    // A tabela precisa estar em ordem crescente, senão o `last { streak >= day }` escolhe o marco errado.
    @Test func testingMilestonesAreSortedAndComplete() {
        let (presenter, _) = createProfilePresenterAndStore()
        let days = presenter.milestones.map(\.day)

        #expect(days.first == 0)
        #expect(days == days.sorted())
        #expect(Set(days).count == days.count)
        #expect(presenter.milestones.allSatisfy { !$0.title.isEmpty && !$0.message.isEmpty })
    }

    @Test(arguments: [Theme.sober, .bubblegum, .pop, .techNature])
    func testingPresentThemeForwardsToStore(theme: Theme) {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentTheme(theme)

        #expect(store.currentTheme == theme)
    }

    @Test func testingPresentEditingForwardsStateAndDraftName() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentEditing(isEditing: true, currentName: "Raquel")

        #expect(store.isEditing)
        #expect(store.draftName == "Raquel")

        presenter.presentEditing(isEditing: false, currentName: "Raquel")

        #expect(store.isEditing == false)
    }

    @Test(arguments: [true, false])
    func testingPresentSettingsSheetForwardsVisibility(isPresented: Bool) {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentSettingsSheet(isPresented: isPresented)

        #expect(store.isSettingsPresented == isPresented)
    }

    // Permissão negada vai para o alerta com "abrir ajustes", não para o de erro.
    @Test func testingPresentLocationDeniedShowsPermissionAlert() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentLocationDenied()

        #expect(store.permissionAlertMessage?.contains("localização") == true)
        #expect(store.errorMessage == nil)
    }

    @Test func testingPresentNotificationsDeniedShowsPermissionAlert() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentNotificationsDenied()

        #expect(store.permissionAlertMessage?.contains("notificações") == true)
        #expect(store.errorMessage == nil)
    }

    @Test func testingPresentPhotoLoadErrorShowsSpecificMessage() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentError(PhotoLibraryError.loadFailed)

        #expect(store.errorMessage == "Não foi possível carregar a foto. Tente outra.")
        #expect(store.permissionAlertMessage == nil)
    }

    @Test func testingPresentUnknownErrorShowsGenericMessage() {
        let (presenter, store) = createProfilePresenterAndStore()

        presenter.presentError(CameraError.captureFailed)

        #expect(store.errorMessage == "Algo deu errado. Tente novamente.")
    }

    @Test func testingPresentAlertsDismissedClearsBothAlerts() {
        let (presenter, store) = createProfilePresenterAndStore()
        presenter.presentLocationDenied()
        presenter.presentError(PhotoLibraryError.loadFailed)

        presenter.presentAlertsDismissed()

        #expect(store.permissionAlertMessage == nil)
        #expect(store.errorMessage == nil)
    }

    // O store é weak: se a tela já foi embora, apresentar não pode quebrar.
    @Test func testingPresentProfileWithoutStoreDoesNotCrash() {
        let presenter: ProfilePresenter
        do {
            let store = ProfileStore()
            presenter = ProfilePresenter(store: store)
        }

        presenter.presentProfile(Profile(name: "Raquel", streak: 3))

        #expect(presenter.store == nil)
    }
}
