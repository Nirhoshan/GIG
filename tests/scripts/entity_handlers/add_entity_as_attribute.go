package entity_handlers

import (
	"GIG/app/models"
	"GIG/app/repositories"
	"GIG/scripts/entity_handlers"
)

func (t *TestEntityHandlers) TestThatAddEntityAsAttributeWorks() {
	attributeEntity := models.Entity{Title: "Sri Lanka"}
	entity := models.Entity{Title: "test entity"}
	entity, attributeEntity, _ = entity_handlers.AddEntityAsAttribute(entity, "testAttribute", attributeEntity)
	entity = repositories.EagerLoad(entity)
	t.AssertEqual(entity.Attributes[0].Values[0].RawValue, "Sri Lanka")

}