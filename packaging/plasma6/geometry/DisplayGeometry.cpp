#include "DisplayGeometry.h"

#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>

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
