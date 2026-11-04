#include "DisplayGeometry.h"

#include <QElapsedTimer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>

namespace {
QElapsedTimer &sharedAnimationClock()
{
    static QElapsedTimer clock = [] {
        QElapsedTimer timer;
        timer.start();
        return timer;
    }();
    return clock;
}
}

QRect DisplayGeometry::screenGeometry(QObject *item) const
{
    auto *quickItem = qobject_cast<QQuickItem *>(item);
    if (!quickItem || !quickItem->window() || !quickItem->window()->screen())
        return {};
    return quickItem->window()->screen()->geometry();
}

QRect DisplayGeometry::virtualGeometry(QObject *item) const
{
    const auto *quickItem = qobject_cast<const QQuickItem *>(item);
    if (!quickItem || !quickItem->window() || !quickItem->window()->screen())
        return {};
    return quickItem->window()->screen()->virtualGeometry();
}

qreal DisplayGeometry::elapsedSeconds() const
{
    return static_cast<qreal>(sharedAnimationClock().nsecsElapsed()) / 1000000000.0;
}
